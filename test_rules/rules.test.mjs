// Security-rules tests for ../firestore.rules
//
// These exist because every authorization decision in CineFile lives in that
// one file and nothing was exercising it. Three real holes were found by
// writing them: a profile could advertise a username it had never claimed,
// a post could carry somebody else's name and avatar, and `starredBy` could
// be pre-stuffed at create time (the star/comment guards only cover updates).
// Each of those has a test below that fails against the old rules.
//
// Run:  npm install && npm test        (needs Java — the Firestore emulator)

import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, setDoc, updateDoc, deleteDoc, collection, addDoc,
  writeBatch, serverTimestamp, increment,
} from 'firebase/firestore';

let env;

const ALICE = 'alice-uid';
const BOB = 'bob-uid';

const DICEBEAR = 'https://api.dicebear.com/7.x/bottts/png?seed=alice';
const BOB_AVATAR = 'https://api.dicebear.com/7.x/bottts/png?seed=bob';

/** A profile document shaped exactly like AuthController._userDocFor writes it. */
function profile(username, avatarUrl) {
  return {
    username,
    usernameLower: username.toLowerCase(),
    avatarUrl,
    bio: '',
    followerCount: 0,
    followingCount: 0,
    featuredMovieIds: [],
  };
}

/** A log document shaped like AddWatchRecordSheet._saveRecord writes it. */
function log(overrides = {}) {
  return {
    userId: ALICE,
    username: 'Alice',
    userAvatarUrl: DICEBEAR,
    movieId: 27205,
    isTv: false,
    watchDate: new Date(),
    rating: 8,
    watchNumber: 1,
    episodeCount: 1,
    createdAt: new Date(),
    movieTitle: 'Inception',
    starredBy: [],
    commentCount: 0,
    isPublic: false,
    ...overrides,
  };
}

/** A post document shaped like ShareComposeSheet._submit writes it. */
function post(overrides = {}) {
  return {
    userId: ALICE,
    username: 'Alice',
    userAvatarUrl: DICEBEAR,
    type: 'movie',
    caption: 'harika film',
    createdAt: new Date(),
    starredBy: [],
    commentCount: 0,
    ...overrides,
  };
}

function comment(overrides = {}) {
  return {
    userId: BOB,
    username: 'Bob',
    userAvatarUrl: BOB_AVATAR,
    text: 'katılıyorum',
    createdAt: new Date(),
    ...overrides,
  };
}

function addCommentBatch(db, overrides = {}) {
  const commentId = 'c1';
  const batch = writeBatch(db);
  batch.set(doc(db, `posts/p1/comments/${commentId}`), comment(overrides));
  batch.update(doc(db, 'posts/p1'), {
    commentCount: increment(1),
    lastCommentMutationId: commentId,
  });
  return batch.commit();
}

function addLogCommentBatch(db, overrides = {}) {
  const commentId = 'c1';
  const batch = writeBatch(db);
  batch.set(doc(db, `logs/l1/comments/${commentId}`), comment(overrides));
  batch.update(doc(db, 'logs/l1'), {
    commentCount: increment(1),
    lastCommentMutationId: commentId,
  });
  return batch.commit();
}

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-cinefile',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await env?.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  // Both users exist with a claimed username, as they would after signup.
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'usernames/alice'), { uid: ALICE });
    await setDoc(doc(db, 'usernames/bob'), { uid: BOB });
    await setDoc(doc(db, 'users', ALICE), profile('Alice', DICEBEAR));
    await setDoc(doc(db, 'users', BOB), profile('Bob', BOB_AVATAR));
  });
});

const asAlice = () => env.authenticatedContext(ALICE).firestore();
const asBob = () => env.authenticatedContext(BOB).firestore();
const asAnon = () => env.unauthenticatedContext().firestore();

// ---------------------------------------------------------------------------

describe('users — username is bound to the /usernames claim', () => {
  it('allows creating your own profile with your claimed username', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await deleteDoc(doc(ctx.firestore(), 'users', ALICE));
    });
    await assertSucceeds(setDoc(doc(asAlice(), 'users', ALICE), profile('Alice', DICEBEAR)));
  });

  it('rejects creating another user profile', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await deleteDoc(doc(ctx.firestore(), 'users', BOB));
    });
    await assertFails(setDoc(doc(asAlice(), 'users', BOB), profile('Bob', BOB_AVATAR)));
  });
  it('rejects a profile advertising a username claimed by someone else', async () => {
    // The impersonation that was possible before: Alice renames herself "Bob".
    await assertFails(
      updateDoc(doc(asAlice(), 'users', ALICE), {
        username: 'Bob',
        usernameLower: 'bob',
      }),
    );
  });

  it('rejects a username nobody has claimed', async () => {
    await assertFails(
      updateDoc(doc(asAlice(), 'users', ALICE), {
        username: 'Ghost',
        usernameLower: 'ghost',
      }),
    );
  });

  it('rejects a usernameLower that does not match the username', async () => {
    // Claim a free name, then try to display a different one under it.
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'usernames/decoy'), { uid: ALICE });
    });
    await assertFails(
      updateDoc(doc(asAlice(), 'users', ALICE), {
        username: 'Bob',
        usernameLower: 'decoy',
      }),
    );
  });

  it('allows renaming to a name this account has claimed', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'usernames/alice2'), { uid: ALICE });
    });
    await assertSucceeds(
      updateDoc(doc(asAlice(), 'users', ALICE), {
        username: 'Alice2',
        usernameLower: 'alice2',
      }),
    );
  });

  it('allows editing bio without touching the username', async () => {
    await assertSucceeds(
      updateDoc(doc(asAlice(), 'users', ALICE), { bio: 'sinefil' }),
    );
  });

  it('rejects an avatar outside the allowlist', async () => {
    await assertFails(
      updateDoc(doc(asAlice(), 'users', ALICE), {
        avatarUrl: 'https://attacker.example/pixel.png',
      }),
    );
  });

  it('rejects an oversized bio', async () => {
    await assertFails(
      updateDoc(doc(asAlice(), 'users', ALICE), { bio: 'x'.repeat(301) }),
    );
  });

  it('rejects writing to another user profile', async () => {
    await assertFails(
      updateDoc(doc(asBob(), 'users', ALICE), { bio: 'hacked' }),
    );
  });

  it('rejects a counter step without the matching follow edge', async () => {
    await assertFails(updateDoc(doc(asBob(), 'users', ALICE), { followerCount: 1 }));
  });

  it('allows counters to move with a matching follow edge in one batch', async () => {
    const db = asBob();
    const batch = writeBatch(db);
    batch.set(doc(db, `follows/${BOB}_${ALICE}`), {
      followerId: BOB, followingId: ALICE, createdAt: serverTimestamp(),
    });
    batch.update(doc(db, 'users', BOB), {
      followingCount: increment(1), lastFollowTargetId: ALICE,
    });
    batch.update(doc(db, 'users', ALICE), { followerCount: increment(1) });
    await assertSucceeds(batch.commit());
  });

  it('rejects an owner directly changing their own counters', async () => {
    await assertFails(
      updateDoc(doc(asAlice(), 'users', ALICE), { followingCount: 10 }),
    );
  });

  it('rejects an arbitrary follower count', async () => {
    await assertFails(
      updateDoc(doc(asBob(), 'users', ALICE), { followerCount: 9999 }),
    );
  });

  it('rejects profile deletion', async () => {
    await assertFails(deleteDoc(doc(asAlice(), 'users', ALICE)));
  });
});

describe('posts — author fields and social counters', () => {
  it('allows publishing with your own identity', async () => {
    await assertSucceeds(addDoc(collection(asAlice(), 'posts'), post()));
  });

  it("rejects a post carrying another user's username", async () => {
    await assertFails(
      addDoc(collection(asAlice(), 'posts'), post({ username: 'Bob' })),
    );
  });

  it("rejects a post carrying another user's avatar", async () => {
    await assertFails(
      addDoc(collection(asAlice(), 'posts'), post({ userAvatarUrl: BOB_AVATAR })),
    );
  });

  it('rejects a post whose avatar points at an arbitrary host', async () => {
    await assertFails(
      addDoc(
        collection(asAlice(), 'posts'),
        post({ userAvatarUrl: 'https://attacker.example/track.gif' }),
      ),
    );
  });

  it('rejects a post created with starredBy pre-filled', async () => {
    await assertFails(
      addDoc(
        collection(asAlice(), 'posts'),
        post({ starredBy: [BOB, 'carol', 'dave'] }),
      ),
    );
  });

  it('rejects a post created with a non-zero commentCount', async () => {
    await assertFails(
      addDoc(collection(asAlice(), 'posts'), post({ commentCount: 500 })),
    );
  });

  it('rejects an oversized caption', async () => {
    await assertFails(
      addDoc(collection(asAlice(), 'posts'), post({ caption: 'x'.repeat(501) })),
    );
  });

  it('rejects posting as another user entirely', async () => {
    await assertFails(
      addDoc(collection(asAlice(), 'posts'), post({ userId: BOB })),
    );
  });

  it('lets another user add exactly their own star', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
    await assertSucceeds(
      updateDoc(doc(asBob(), 'posts/p1'), { starredBy: [BOB] }),
    );
  });

  it('rejects stuffing the star list with other uids', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
    await assertFails(
      updateDoc(doc(asBob(), 'posts/p1'), { starredBy: [BOB, 'carol'] }),
    );
  });

  it('rejects the owner manufacturing stars', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
    await assertFails(
      updateDoc(doc(asAlice(), 'posts/p1'), { starredBy: [BOB] }),
    );
  });

  it('rejects the owner transferring authorship', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
    await assertFails(
      updateDoc(doc(asAlice(), 'posts/p1'), {
        userId: BOB, username: 'Bob', userAvatarUrl: BOB_AVATAR,
      }),
    );
  });

  it('still lets the owner edit ordinary post content', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
    await assertSucceeds(
      updateDoc(doc(asAlice(), 'posts/p1'), { caption: 'd\u00fczenlendi' }),
    );
  });

  it('rejects ordinary content updates by a non-owner', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
    await assertFails(updateDoc(doc(asBob(), 'posts/p1'), { caption: 'hacked' }));
  });

  it('allows deletion by the owner', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
    await assertSucceeds(deleteDoc(doc(asAlice(), 'posts/p1')));
  });

  it('rejects deletion by a non-owner', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
    await assertFails(deleteDoc(doc(asBob(), 'posts/p1')));
  });

  it('rejects reads while signed out', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
    await assertFails(getDoc(doc(asAnon(), 'posts/p1')));
  });
});

describe('logs — privacy and authorship', () => {
  it('allows the owner to create their own log', async () => {
    await assertSucceeds(addDoc(collection(asAlice(), 'logs'), log()));
  });

  it("rejects a log carrying another user's username", async () => {
    await assertFails(
      addDoc(collection(asAlice(), 'logs'), log({ username: 'Bob' })),
    );
  });

  it('rejects oversized notes', async () => {
    await assertFails(
      addDoc(collection(asAlice(), 'logs'), log({ notes: 'x'.repeat(2001) })),
    );
  });

  it('hides a private log from another user', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'logs/l1'), log({ isPublic: false }));
    });
    await assertFails(getDoc(doc(asBob(), 'logs/l1')));
  });

  it('shows the owner their own private log', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'logs/l1'), log({ isPublic: false }));
    });
    await assertSucceeds(getDoc(doc(asAlice(), 'logs/l1')));
  });

  it('shows a public log to another user', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'logs/l1'), log({ isPublic: true }));
    });
    await assertSucceeds(getDoc(doc(asBob(), 'logs/l1')));
  });

  it('rejects another user editing the log body', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'logs/l1'), log({ isPublic: true }));
    });
    await assertFails(updateDoc(doc(asBob(), 'logs/l1'), { rating: 1 }));
  });

  it('rejects another user deleting the log', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'logs/l1'), log({ isPublic: true }));
    });
    await assertFails(deleteDoc(doc(asBob(), 'logs/l1')));
  });

  it('allows the owner to update ordinary log content', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'logs/l1'), log());
    });
    await assertSucceeds(updateDoc(doc(asAlice(), 'logs/l1'), { rating: 9 }));
  });

  it('allows the owner to delete their log', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'logs/l1'), log());
    });
    await assertSucceeds(deleteDoc(doc(asAlice(), 'logs/l1')));
  });

  it('rejects the owner changing log identity or social counters', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'logs/l1'), log());
    });
    await assertFails(
      updateDoc(doc(asAlice(), 'logs/l1'), { commentCount: 500 }),
    );
    await assertFails(
      updateDoc(doc(asAlice(), 'logs/l1'), { userId: BOB }),
    );
  });
});

describe('comments — authorship', () => {
  beforeEach(async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
  });

  it('allows a comment with your own identity', async () => {
    await assertSucceeds(addCommentBatch(asBob()));
  });

  it('rejects creating a comment without stepping the parent counter', async () => {
    await assertFails(
      setDoc(doc(asBob(), 'posts/p1/comments/orphan'), comment()),
    );
  });

  it('rejects stepping the counter without creating the named comment', async () => {
    await assertFails(
      updateDoc(doc(asBob(), 'posts/p1'), {
        commentCount: increment(1), lastCommentMutationId: 'missing',
      }),
    );
  });

  it("rejects a comment carrying another user's username", async () => {
    await assertFails(addCommentBatch(asBob(), {
      username: 'Alice', userAvatarUrl: DICEBEAR,
    }));
  });

  it('rejects an oversized comment', async () => {
    await assertFails(addCommentBatch(asBob(), { text: 'x'.repeat(1001) }));
  });

  it('rejects editing a comment', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1/comments/c1'), {
        userId: BOB, username: 'Bob', userAvatarUrl: BOB_AVATAR,
        text: 'ilk', createdAt: new Date(),
      });
    });
    await assertFails(
      updateDoc(doc(asBob(), 'posts/p1/comments/c1'), { text: 'düzenlendi' }),
    );
  });

  it('allows the author to delete only with the matching counter decrement', async () => {
    await assertSucceeds(addCommentBatch(asBob()));
    const db = asBob();
    const batch = writeBatch(db);
    batch.delete(doc(db, 'posts/p1/comments/c1'));
    batch.update(doc(db, 'posts/p1'), {
      commentCount: increment(-1), lastCommentMutationId: 'c1',
    });
    await assertSucceeds(batch.commit());
  });

  it('rejects deleting a comment without decrementing the counter', async () => {
    await assertSucceeds(addCommentBatch(asBob()));
    await assertFails(deleteDoc(doc(asBob(), 'posts/p1/comments/c1')));
  });

  it('rejects decrementing the counter below zero', async () => {
    await assertFails(
      updateDoc(doc(asBob(), 'posts/p1'), {
        commentCount: increment(-1), lastCommentMutationId: 'missing',
      }),
    );
  });
});

describe('log comments — create/update/delete matrix', () => {
  beforeEach(async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'logs/l1'), log({ isPublic: true }));
    });
  });

  it('allows create and author delete with matching parent counter steps', async () => {
    await assertSucceeds(addLogCommentBatch(asBob()));
    const db = asBob();
    const batch = writeBatch(db);
    batch.delete(doc(db, 'logs/l1/comments/c1'));
    batch.update(doc(db, 'logs/l1'), {
      commentCount: increment(-1), lastCommentMutationId: 'c1',
    });
    await assertSucceeds(batch.commit());
  });

  it('rejects create or delete without the matching parent counter step', async () => {
    await assertFails(setDoc(doc(asBob(), 'logs/l1/comments/orphan'), comment()));
    await assertSucceeds(addLogCommentBatch(asBob()));
    await assertFails(deleteDoc(doc(asBob(), 'logs/l1/comments/c1')));
  });

  it('rejects comment updates', async () => {
    await assertSucceeds(addLogCommentBatch(asBob()));
    await assertFails(updateDoc(doc(asBob(), 'logs/l1/comments/c1'), { text: 'edited' }));
  });
});

describe('shared_collections — owner identity', () => {
  const sharedCollection = (overrides = {}) => ({
    ownerId: ALICE,
    ownerUsername: 'Alice',
    ownerAvatarUrl: DICEBEAR,
    name: 'Noir Maratonu',
    description: '',
    movies: [],
    ...overrides,
  });

  it('allows the owner to publish a mirror', async () => {
    await assertSucceeds(
      setDoc(doc(asAlice(), `shared_collections/${ALICE}_1`), sharedCollection()),
    );
  });

  it("rejects a mirror carrying another user's name", async () => {
    await assertFails(
      setDoc(
        doc(asAlice(), `shared_collections/${ALICE}_1`),
        sharedCollection({ ownerUsername: 'Bob' }),
      ),
    );
  });

  it('rejects publishing on behalf of another user', async () => {
    await assertFails(
      setDoc(
        doc(asBob(), `shared_collections/${ALICE}_1`),
        sharedCollection(),
      ),
    );
  });

  it('lets the owner delete their mirror (the "stop sharing" path)', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `shared_collections/${ALICE}_1`),
        sharedCollection(),
      );
    });
    await assertSucceeds(
      deleteDoc(doc(asAlice(), `shared_collections/${ALICE}_1`)),
    );
  });

  it('allows only the owner to update a mirror without changing ownership', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `shared_collections/${ALICE}_1`), sharedCollection());
    });
    await assertSucceeds(updateDoc(doc(asAlice(), `shared_collections/${ALICE}_1`), { name: 'Yeni ad' }));
    await assertFails(updateDoc(doc(asBob(), `shared_collections/${ALICE}_1`), { name: 'Hacked' }));
    await assertFails(updateDoc(doc(asAlice(), `shared_collections/${ALICE}_1`), { ownerId: BOB }));
  });

  it('rejects deletion by a non-owner', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `shared_collections/${ALICE}_1`),
        sharedCollection(),
      );
    });
    await assertFails(
      deleteDoc(doc(asBob(), `shared_collections/${ALICE}_1`)),
    );
  });
});

describe('usernames registry', () => {
  it('rejects claiming a name already held by someone else', async () => {
    await assertFails(
      setDoc(doc(asAlice(), 'usernames/bob'), { uid: ALICE }),
    );
  });

  it('rejects claiming a name for a different uid', async () => {
    await assertFails(
      setDoc(doc(asAlice(), 'usernames/free'), { uid: BOB }),
    );
  });

  it('allows claiming a free name for yourself', async () => {
    await assertSucceeds(
      setDoc(doc(asAlice(), 'usernames/free'), { uid: ALICE }),
    );
  });

  it("rejects releasing another user's claim", async () => {
    await assertFails(deleteDoc(doc(asAlice(), 'usernames/bob')));
  });

  it('allows releasing your own claim and rejects claim updates', async () => {
    await assertSucceeds(deleteDoc(doc(asAlice(), 'usernames/alice')));
    await assertFails(updateDoc(doc(asBob(), 'usernames/bob'), { uid: ALICE }));
  });

  // AuthController._claimUsername reads this doc inside a transaction, so
  // read access is required — locking it down would break signup.
  it('allows a signed-in read (required by the claim transaction)', async () => {
    await assertSucceeds(getDoc(doc(asAlice(), 'usernames/bob')));
  });
});

describe('follows — edge and counters stay atomic', () => {
  it('rejects creating an edge without moving both counters', async () => {
    await assertFails(
      setDoc(doc(asBob(), `follows/${BOB}_${ALICE}`), {
        followerId: BOB, followingId: ALICE, createdAt: serverTimestamp(),
      }),
    );
  });

  it('rejects an edge whose document id does not match its users', async () => {
    const db = asBob();
    const batch = writeBatch(db);
    batch.set(doc(db, 'follows/arbitrary-id'), {
      followerId: BOB, followingId: ALICE, createdAt: serverTimestamp(),
    });
    batch.update(doc(db, 'users', BOB), {
      followingCount: increment(1), lastFollowTargetId: ALICE,
    });
    batch.update(doc(db, 'users', ALICE), { followerCount: increment(1) });
    await assertFails(batch.commit());
  });

  it('allows deleting an edge only while decrementing both counters', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, `follows/${BOB}_${ALICE}`), {
        followerId: BOB, followingId: ALICE, createdAt: new Date(),
      });
      await updateDoc(doc(db, 'users', BOB), {
        followingCount: 1, lastFollowTargetId: ALICE,
      });
      await updateDoc(doc(db, 'users', ALICE), { followerCount: 1 });
    });

    const db = asBob();
    const batch = writeBatch(db);
    batch.delete(doc(db, `follows/${BOB}_${ALICE}`));
    batch.update(doc(db, 'users', BOB), {
      followingCount: increment(-1), lastFollowTargetId: ALICE,
    });
    batch.update(doc(db, 'users', ALICE), { followerCount: increment(-1) });
    await assertSucceeds(batch.commit());
  });
  it('rejects edge updates and deletion without counter decrements', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `follows/${BOB}_${ALICE}`), {
        followerId: BOB, followingId: ALICE, createdAt: new Date(),
      });
    });
    await assertFails(updateDoc(doc(asBob(), `follows/${BOB}_${ALICE}`), { followingId: BOB }));
    await assertFails(deleteDoc(doc(asBob(), `follows/${BOB}_${ALICE}`)));
  });

});

describe('per-user subcollections stay private', () => {
  it("rejects reading another user's movie_settings", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `users/${ALICE}/movie_settings/27205_false`), {
        movieId: 27205, isTv: false, isFavorite: true,
      });
    });
    await assertFails(
      getDoc(doc(asBob(), `users/${ALICE}/movie_settings/27205_false`)),
    );
  });

  it("rejects reading another user's graph_overrides", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `users/${ALICE}/graph_overrides/global`), {
        hiddenPersonKeys: [],
      });
    });
    await assertFails(
      getDoc(doc(asBob(), `users/${ALICE}/graph_overrides/global`)),
    );
  });

  // Regression guard for the id this document used to use. Firestore reserves
  // ids matching `__.*__`, so the old `__global__` made every "hide person"
  // write fail with INVALID_ARGUMENT — the feature had never worked. This
  // asserts the emulator still rejects it, so nothing reintroduces the shape.
  // Not assertFails(): that helper only recognises PERMISSION_DENIED, and this
  // is rejected by Firestore itself with INVALID_ARGUMENT before rules ever
  // run — which is exactly why the bug was invisible to the rules review.
  it('rejects a reserved __...__ document id', async () => {
    let code = null;
    try {
      await setDoc(doc(asAlice(), `users/${ALICE}/graph_overrides/__global__`), {
        hiddenPersonKeys: [],
      });
    } catch (e) {
      code = e.code;
    }
    assert.strictEqual(code, 'invalid-argument');
  });

  it('allows the owner to write their own movie_settings', async () => {
    await assertSucceeds(
      setDoc(doc(asAlice(), `users/${ALICE}/movie_settings/27205_false`), {
        movieId: 27205, isTv: false, isFavorite: true,
      }),
    );
  });

  for (const subcollection of ['movie_settings', 'graph_overrides']) {
    it(`allows owner and rejects non-owner create/update/delete for ${subcollection}`, async () => {
      const path = `users/${ALICE}/${subcollection}/matrix`;
      await assertSucceeds(setDoc(doc(asAlice(), path), { value: 1 }));
      await assertFails(setDoc(doc(asBob(), `${path}-other`), { value: 1 }));
      await assertSucceeds(updateDoc(doc(asAlice(), path), { value: 2 }));
      await assertFails(updateDoc(doc(asBob(), path), { value: 3 }));
      await assertFails(deleteDoc(doc(asBob(), path)));
      await assertSucceeds(deleteDoc(doc(asAlice(), path)));
    });
  }
});
