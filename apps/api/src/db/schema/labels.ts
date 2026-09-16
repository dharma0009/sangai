import {
  pgTable,
  uuid,
  varchar,
  unique,
} from "drizzle-orm/pg-core";

import { projects } from "./projects.js";
import { issues } from "./issues.js";

export const labels = pgTable(
  "labels",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    projectId: uuid("project_id")
      .notNull()
      .references(() => projects.id, {
        onDelete: "cascade",
      }),

    name: varchar("name", {
      length: 50,
    }).notNull(),
  },
  (table) => [
    unique("label_name_per_project").on(
      table.projectId,
      table.name,
    ),
  ],
);

export const issueLabels = pgTable(
  "issue_labels",
  {
    issueId: uuid("issue_id")
      .notNull()
      .references(() => issues.id, {
        onDelete: "cascade",
      }),

    labelId: uuid("label_id")
      .notNull()
      .references(() => labels.id, {
        onDelete: "cascade",
      }),
  },
  (table) => [
    unique("issue_label_unique").on(
      table.issueId,
      table.labelId,
    ),
  ],
);