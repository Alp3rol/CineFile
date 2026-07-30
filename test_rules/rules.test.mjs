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

  it('still allows the follow-counter step on another user', async () => {
    await assertSucceeds(
      updateDoc(doc(asBob(), 'users', ALICE), { followerCount: 1 }),
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
});

describe('comments — authorship', () => {
  beforeEach(async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'posts/p1'), post());
    });
  });

  it('allows a comment with your own identity', async () => {
    await assertSucceeds(
      addDoc(collection(asBob(), 'posts/p1/comments'), {
        userId: BOB, username: 'Bob', userAvatarUrl: BOB_AVATAR,
        text: 'katılıyorum', createdAt: new Date(),
      }),
    );
  });

  it("rejects a comment carrying another user's username", async () => {
    await assertFails(
      addDoc(collection(asBob(), 'posts/p1/comments'), {
        userId: BOB, username: 'Alice', userAvatarUrl: DICEBEAR,
        text: 'sahte', createdAt: new Date(),
      }),
    );
  });

  it('rejects an oversized comment', async () => {
    await assertFails(
      addDoc(collection(asBob(), 'posts/p1/comments'), {
        userId: BOB, username: 'Bob', userAvatarUrl: BOB_AVATAR,
        text: 'x'.repeat(1001), createdAt: new Date(),
      }),
    );
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

  // AuthController._claimUsername reads this doc inside a transaction, so
  // read access is required — locking it down would break signup.
  it('allows a signed-in read (required by the claim transaction)', async () => {
    await assertSucceeds(getDoc(doc(asAlice(), 'usernames/bob')));
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
});
