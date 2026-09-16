import {
  pgEnum,
  pgTable,
  uuid,
  varchar,
  timestamp,
  unique,
} from "drizzle-orm/pg-core";

import { users } from "./users.js";

export const organizationRoleEnum = pgEnum("organization_role", [
  "OWNER",
  "ADMIN",
  "MEMBER",
  "VIEWER",
]);

export const organizations = pgTable("organizations", {
  id: uuid("id").defaultRandom().primaryKey(),

  name: varchar("name", {
    length: 150,
  }).notNull(),

  slug: varchar("slug", {
    length: 100,
  }).notNull().unique(),

  createdAt: timestamp("created_at", {
    withTimezone: true,
  }).defaultNow().notNull(),

  updatedAt: timestamp("updated_at", {
    withTimezone: true,
  }).defaultNow().notNull(),
});

export const organizationMembers = pgTable(
  "organization_members",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, {
        onDelete: "cascade",
      }),

    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, {
        onDelete: "cascade",
      }),

    role: organizationRoleEnum("role")
      .notNull()
      .default("MEMBER"),

    joinedAt: timestamp("joined_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    unique("organization_member_unique").on(
      table.organizationId,
      table.userId,
    ),
  ],
);