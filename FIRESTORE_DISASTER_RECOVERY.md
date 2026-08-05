# Firestore backup and recovery runbook

Status: **procedure prepared; production backup schedule and cross-project drill
are not yet verified**. Creating them requires billing, a Storage bucket, Cloud
permissions, and an explicitly selected empty test project. No production data
was changed while preparing this runbook.

## Objectives and ownership

- Production project/database: `cinefile-6252a` / `(default)`.
- Owner: repository/Firebase project owner. A second named operator should be
  added before the application has business-critical usage.
- Target RPO: 24 hours from daily scheduled backup; 7 days of minute-level
  recovery if PITR is enabled.
- Target RTO: 4 hours to select, restore, validate, and switch/reopen writes.
- Drill frequency: quarterly and after any schema/security-rules migration.
- Retention: daily scheduled backups for 14 weeks; weekly managed exports in
  Cloud Storage for 180 days using a bucket lifecycle rule.

## Data inventory

An operational backup must cover the **entire database**. Exporting only the
top-level names misses nested collection groups.

| Collection group | Location | Purpose |
|---|---|---|
| `logs` | top level | private/public diary records |
| `comments` | under `logs` and `posts` | social comments |
| `posts` | top level | community posts |
| `shared_collections` | top level | explicitly shared lists |
| `users` | top level | profiles and social counters |
| `movie_settings` | under users | favorites, progress, title settings |
| `graph_overrides` | under users | relationship graph edits |
| `usernames` | top level | unique username claims |
| `follows` | top level | follow edges |

Firestore backups do not include Firebase Authentication users, Cloud Storage
objects, or local Drift/browser data. The in-app JSON export is a user-level
portability tool and does not replace this server-side backup.

## One-time production setup

Use Google Cloud Console/Cloud Shell with the production project visibly
selected. Managed export/import requires billing (Firebase Blaze), and the
bucket must be close to the Firestore database location. Do not use Requester
Pays or Rapid buckets.

1. Record the Firestore location and project number.
2. Enable billing and create a dedicated bucket such as
   `gs://cinefile-6252a-firestore-backups` in the same/nearby location.
3. Confirm the Firestore service agent
   `service-521976219913@gcp-sa-firestore.iam.gserviceaccount.com` can access
   the bucket. Same-project buckets normally work by default; cross-project
   restore requires explicit bucket access for the target service agent.
4. Create the daily consistent backup schedule:

   ```text
   gcloud firestore backups schedules create --database='(default)' --retention=14w --recurrence=daily --project=cinefile-6252a
   ```

5. Enable PITR in Firestore disaster-recovery settings if the cost is accepted.
6. Add a 180-day lifecycle deletion rule to the managed-export bucket.
7. List and record the schedule:

   ```text
   gcloud firestore backups schedules list --database='(default)' --project=cinefile-6252a
   gcloud firestore backups list --project=cinefile-6252a --format="table(name,database,state,snapshotTime,expireTime)"
   ```

## Managed export

Preview the exact operation locally (safe; no cloud write):

```text
powershell -NoProfile -ExecutionPolicy Bypass -File tool/firestore_export.ps1 -Bucket gs://cinefile-6252a-firestore-backups
```

To run it from authenticated Cloud Shell or a machine with `gcloud`, add
`-Execute -Confirmation "BACKUP cinefile-6252a"`. The script validates the
active project and waits for completion. Managed exports are not perfectly
point-in-time snapshots and cost one document read per exported document.

After completion, retain the full printed `gs://.../timestamp` path and confirm
the export metadata object exists. Never rename or move individual files inside
an export directory.

## Quarterly restore drill (never production first)

1. Create/select a separate Blaze test project with an empty Native-mode
   `(default)` Firestore database in a compatible location.
2. Grant that project's Firestore service agent read access to the source
   export bucket.
3. Preview the guarded import:

   ```text
   powershell -NoProfile -ExecutionPolicy Bypass -File tool/firestore_restore_drill.ps1 -SourceExport gs://BUCKET/cinefile-managed-exports/TIMESTAMP -TargetProjectId cinefile-restore-test
   ```

4. Execute only after verifying both project IDs:

   ```text
   powershell -NoProfile -ExecutionPolicy Bypass -File tool/firestore_restore_drill.ps1 -SourceExport gs://BUCKET/cinefile-managed-exports/TIMESTAMP -TargetProjectId cinefile-restore-test -Execute -Confirmation "RESTORE cinefile-restore-test"
   ```

5. Compare document counts for all nine collection groups and inspect at least
   one user with a log, movie setting, post, both comment parents, shared list,
   username claim, follow edge, and graph override.
6. Deploy `firestore.rules` and `firestore.indexes.json` to the test project;
   managed export/import transfers documents, not the repository's rules.
7. Run the 77-rule emulator suite and a manual read-only app smoke test against
   the test project. Record start/end time, export path, counts, discrepancies,
   and operator in the drill log below.
8. Delete the test database/project only after evidence is recorded.

Import merges data: matching document IDs overwrite, but unrelated target
documents remain. That is why the drill target must be empty.

## Production recovery decision tree

1. Stop deployments and announce maintenance; preserve logs/evidence.
2. Identify incident time and scope. For a narrow user error, prefer the
   in-app account restore. For recent broad corruption, select PITR. For wider
   loss, use the newest known-good scheduled backup/export.
3. Never test the chosen artifact against production. Restore it to a new
   database/test project and perform the validation checklist first.
4. Take a final export of the damaged production state before any recovery.
5. Prefer restoring a scheduled backup to a **new database**. Firestore backup
   restore does not overwrite an existing database. Application routing to a
   named database must be tested before cutover.
6. If importing into `(default)` is unavoidable, understand that import is a
   merge, not a rollback: extra corrupt documents must be identified and
   removed separately. Require a second-person review before production import.
7. Reapply/verify rules, indexes, TTL settings (scheduled backups do not contain
   TTL policies), App Check enforcement, and Authentication configuration.
8. Run synthetic health and representative authenticated reads, reopen writes,
   then monitor errors and counts for at least one hour.

## Drill log

| Date | Operator | Artifact | Target | Result | RPO | RTO | Notes |
|---|---|---|---|---|---|---|---|
| _pending_ | — | — | — | Not yet executed | — | — | Requires bucket, billing, gcloud and test project |

## Authoritative references

- Firebase managed export/import: https://firebase.google.com/docs/firestore/manage-data/export-import
- Firestore scheduled backups: https://cloud.google.com/firestore/docs/backups
- Disaster recovery planning: https://docs.cloud.google.com/firestore/native/docs/disaster-recovery
