import {
  pgEnum,
  pgTable,
  uuid,
  varchar,
  text,
  date,
  timestamp,
} from "drizzle-orm/pg-core";

import { projects } from "./projects.js";

export const sprintStatusEnum = pgEnum("sprint_status", [
  "PLANNED",
  "ACTIVE",
  "COMPLETED",
]);

export const sprints = pgTable("sprints", {
  id: uuid("id").defaultRandom().primaryKey(),

  projectId: uuid("project_id")
    .notNull()
    .references(() => projects.id, {
      onDelete: "cascade",
    }),

  name: varchar("name", {
    length: 150,
  }).notNull(),

  goal: text("goal"),

  startDate: date("start_date"),

  endDate: date("end_date"),

  status: sprintStatusEnum("status")
    .notNull()
    .default("PLANNED"),

  createdAt: timestamp("created_at", {
    withTimezone: true, 
  }).defaultNow().notNull(),
});