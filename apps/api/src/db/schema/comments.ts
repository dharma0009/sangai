import {
  pgTable,
  uuid,
  text,
  timestamp,
  index,
} from "drizzle-orm/pg-core";

import { issues } from "./issues.js";
import { users } from "./users.js";

export const comments = pgTable(
  "comments",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    issueId: uuid("issue_id")
      .notNull()
      .references(() => issues.id, {
        onDelete: "cascade",
      }),

    authorId: uuid("author_id")
      .notNull()
      .references(() => users.id),

    content: text("content").notNull(),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),

    updatedAt: timestamp("updated_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    index("comments_issue_idx").on(table.issueId),
  ],
);