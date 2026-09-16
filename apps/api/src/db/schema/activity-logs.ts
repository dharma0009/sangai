import {
  pgTable,
  uuid,
  varchar,
  text,
  jsonb,
  timestamp,
  index,
} from "drizzle-orm/pg-core";

import { organizations } from "./organizations.js";
import { users } from "./users.js";

export const activityLogs = pgTable(
  "activity_logs",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    organizationId: uuid("organization_id")
      .notNull()
      .references(() => organizations.id, {
        onDelete: "cascade",
      }),

    userId: uuid("user_id")
      .notNull()
      .references(() => users.id),

    entityType: varchar("entity_type", {
      length: 50,
    }).notNull(),

    entityId: uuid("entity_id").notNull(),

    action: varchar("action", {
      length: 50,
    }).notNull(),

    metadata: jsonb("metadata"),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    index("activity_org_idx").on(table.organizationId),

    index("activity_entity_idx").on(
      table.entityType,
      table.entityId,
    ),
  ],
);