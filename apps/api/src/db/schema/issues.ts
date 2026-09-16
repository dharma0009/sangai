import {
  pgEnum,
  pgTable,
  uuid,
  varchar,
  text,
  integer,
  date,
  timestamp,
  index,
  unique,
} from "drizzle-orm/pg-core";

import { projects } from "./projects.js";
import { users } from "./users.js";
import { sprints } from "./sprints.js";

export const issueStatusEnum = pgEnum("issue_status", [
  "BACKLOG",
  "TODO",
  "IN_PROGRESS",
  "IN_REVIEW",
  "DONE",
]);

export const issuePriorityEnum = pgEnum("issue_priority", [
  "LOW",
  "MEDIUM",
  "HIGH",
  "URGENT",
]);

export const issueTypeEnum = pgEnum("issue_type", [
  "TASK",
  "BUG",
  "FEATURE",
  "IMPROVEMENT",
]);

export const issues = pgTable(
  "issues",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    projectId: uuid("project_id")
      .notNull()
      .references(() => projects.id, {
        onDelete: "cascade",
      }),

    issueNumber: integer("issue_number").notNull(),

    title: varchar("title", {
      length: 255,
    }).notNull(),

    description: text("description"),

    status: issueStatusEnum("status")
      .notNull()
      .default("BACKLOG"),

    priority: issuePriorityEnum("priority")
      .notNull()
      .default("MEDIUM"),

    issueType: issueTypeEnum("issue_type")
      .notNull()
      .default("TASK"),

    reporterId: uuid("reporter_id")
      .notNull()
      .references(() => users.id),

    assigneeId: uuid("assignee_id").references(() => users.id),

    sprintId: uuid("sprint_id").references(() => sprints.id, {
      onDelete: "set null",
    }),

    dueDate: date("due_date"),

    estimate: integer("estimate"),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),

    updatedAt: timestamp("updated_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    unique("issue_number_per_project").on(
      table.projectId,
      table.issueNumber,
    ),

    index("issues_project_idx").on(table.projectId),

    index("issues_assignee_idx").on(table.assigneeId),

    index("issues_status_idx").on(table.status),

    index("issues_sprint_idx").on(table.sprintId),
  ],
);