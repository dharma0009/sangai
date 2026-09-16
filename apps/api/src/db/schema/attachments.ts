import {
  pgTable,
  uuid,
  varchar,
  bigint,
  timestamp,
} from "drizzle-orm/pg-core";

import { issues } from "./issues.js";
import { users } from "./users.js";

export const attachments = pgTable("attachments", {
  id: uuid("id").defaultRandom().primaryKey(),

  issueId: uuid("issue_id")
    .notNull()
    .references(() => issues.id, {
      onDelete: "cascade",
    }),

  uploadedBy: uuid("uploaded_by")
    .notNull()
    .references(() => users.id),

  fileName: varchar("file_name", {
    length: 255,
  }).notNull(),

  fileUrl: varchar("file_url", {
    length: 1000,
  }).notNull(),

  fileSize: bigint("file_size", {
    mode: "number",
  }).notNull(),

  mimeType: varchar("mime_type", {
    length: 100,
  }).notNull(),

  createdAt: timestamp("created_at", {
    withTimezone: true,
  }).defaultNow().notNull(),
});