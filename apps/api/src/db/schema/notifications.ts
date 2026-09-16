import {
  pgTable,
  uuid,
  varchar,
  text,
  jsonb,
  timestamp,
  index,
} from "drizzle-orm/pg-core";

import { users } from "./users.js";

export const notifications = pgTable(
  "notifications",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, {
        onDelete: "cascade",
      }),

    type: varchar("type", {
      length: 50,
    }).notNull(),

    title: varchar("title", {
      length: 255,
    }).notNull(),

    message: text("message").notNull(),

    data: jsonb("data"),

    readAt: timestamp("read_at", {
      withTimezone: true,
    }),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    index("notifications_user_idx").on(table.userId),
  ],
);