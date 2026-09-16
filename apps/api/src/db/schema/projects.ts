import {
  pgEnum,
  pgTable,
  uuid,
  varchar,
  text,
  timestamp,
  unique,
} from "drizzle-orm/pg-core";

import { organizations } from "./organizations.js";
import { users } from "./users.js";

export const projectStatusEnum = pgEnum("project_status", [
  "ACTIVE",
  "ARCHIVED",
]);

export const projectRoleEnum = pgEnum("project_role", [
  "MANAGER",
  "DEVELOPER",
  "VIEWER",
]);

export const projects = pgTable(
  "projects",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, {
        onDelete: "cascade",
      }),

    name: varchar("name", {
      length: 150,
    }).notNull(),

    key: varchar("key", {
      length: 10,
    }).notNull(),

    description: text("description"),

    status: projectStatusEnum("status")
      .notNull()
      .default("ACTIVE"),

    createdBy: uuid("created_by")
      .notNull()
      .references(() => users.id),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),

    updatedAt: timestamp("updated_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    unique("project_key_per_organization").on(
      table.organizationId,
      table.key,
    ),
  ],
);

export const projectMembers = pgTable(
  "project_members",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    projectId: uuid("project_id")
      .notNull()
      .references(() => projects.id, {
        onDelete: "cascade",
      }),

    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, {
        onDelete: "cascade",
      }),

    role: projectRoleEnum("role")
      .notNull()
      .default("DEVELOPER"),

    joinedAt: timestamp("joined_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    unique("project_member_unique").on(
      table.projectId,
      table.userId,
    ),
  ],
);