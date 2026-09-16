import {
  pgTable,
  uuid,
  varchar,
  timestamp,
  index,
} from "drizzle-orm/pg-core";

import { users } from "./users.js";

export const refreshTokens = pgTable(
  "refresh_tokens",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, {
        onDelete: "cascade",
      }),

    tokenHash: varchar("token_hash", {
      length: 255,
    }).notNull(),

    expiresAt: timestamp("expires_at", {
      withTimezone: true,
    }).notNull(),

    revokedAt: timestamp("revoked_at", {
      withTimezone: true,
    }),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    index("refresh_tokens_user_idx").on(table.userId),
  ],
);