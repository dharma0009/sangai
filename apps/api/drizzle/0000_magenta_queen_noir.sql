CREATE TYPE "public"."organization_role" AS ENUM('OWNER', 'ADMIN', 'MEMBER', 'VIEWER');--> statement-breakpoint
CREATE TYPE "public"."project_role" AS ENUM('MANAGER', 'DEVELOPER', 'VIEWER');--> statement-breakpoint
CREATE TYPE "public"."project_status" AS ENUM('ACTIVE', 'ARCHIVED');--> statement-breakpoint
CREATE TYPE "public"."sprint_status" AS ENUM('PLANNED', 'ACTIVE', 'COMPLETED');--> statement-breakpoint
CREATE TYPE "public"."issue_priority" AS ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT');--> statement-breakpoint
CREATE TYPE "public"."issue_status" AS ENUM('BACKLOG', 'TODO', 'IN_PROGRESS', 'IN_REVIEW', 'DONE');--> statement-breakpoint
CREATE TYPE "public"."issue_type" AS ENUM('TASK', 'BUG', 'FEATURE', 'IMPROVEMENT');--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar(100) NOT NULL,
	"email" varchar(255) NOT NULL,
	"password_hash" varchar(255) NOT NULL,
	"avatar_url" varchar(500),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "organization_members" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"user_id" uuid NOT NULL,
	"role" "organization_role" DEFAULT 'MEMBER' NOT NULL,
	"joined_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "organization_member_unique" UNIQUE("organization_id","user_id")
);
--> statement-breakpoint
CREATE TABLE "organizations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar(150) NOT NULL,
	"slug" varchar(100) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "organizations_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "project_members" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"project_id" uuid NOT NULL,
	"user_id" uuid NOT NULL,
	"role" "project_role" DEFAULT 'DEVELOPER' NOT NULL,
	"joined_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "project_member_unique" UNIQUE("project_id","user_id")
);
--> statement-breakpoint
CREATE TABLE "projects" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"name" varchar(150) NOT NULL,
	"key" varchar(10) NOT NULL,
	"description" text,
	"status" "project_status" DEFAULT 'ACTIVE' NOT NULL,
	"created_by" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "project_key_per_organization" UNIQUE("organization_id","key")
);
--> statement-breakpoint
CREATE TABLE "sprints" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"project_id" uuid NOT NULL,
	"name" varchar(150) NOT NULL,
	"goal" text,
	"start_date" date,
	"end_date" date,
	"status" "sprint_status" DEFAULT 'PLANNED' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "issues" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"project_id" uuid NOT NULL,
	"issue_number" integer NOT NULL,
	"title" varchar(255) NOT NULL,
	"description" text,
	"status" "issue_status" DEFAULT 'BACKLOG' NOT NULL,
	"priority" "issue_priority" DEFAULT 'MEDIUM' NOT NULL,
	"issue_type" "issue_type" DEFAULT 'TASK' NOT NULL,
	"reporter_id" uuid NOT NULL,
	"assignee_id" uuid,
	"sprint_id" uuid,
	"due_date" date,
	"estimate" integer,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "issue_number_per_project" UNIQUE("project_id","issue_number")
);
--> statement-breakpoint
CREATE TABLE "issue_labels" (
	"issue_id" uuid NOT NULL,
	"label_id" uuid NOT NULL,
	CONSTRAINT "issue_label_unique" UNIQUE("issue_id","label_id")
);
--> statement-breakpoint
CREATE TABLE "labels" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"project_id" uuid NOT NULL,
	"name" varchar(50) NOT NULL,
	CONSTRAINT "label_name_per_project" UNIQUE("project_id","name")
);
--> statement-breakpoint
CREATE TABLE "comments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"issue_id" uuid NOT NULL,
	"author_id" uuid NOT NULL,
	"content" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "attachments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"issue_id" uuid NOT NULL,
	"uploaded_by" uuid NOT NULL,
	"file_name" varchar(255) NOT NULL,
	"file_url" varchar(1000) NOT NULL,
	"file_size" bigint NOT NULL,
	"mime_type" varchar(100) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "notifications" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"type" varchar(50) NOT NULL,
	"title" varchar(255) NOT NULL,
	"message" text NOT NULL,
	"data" jsonb,
	"read_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "activity_logs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"user_id" uuid NOT NULL,
	"entity_type" varchar(50) NOT NULL,
	"entity_id" uuid NOT NULL,
	"action" varchar(50) NOT NULL,
	"metadata" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "refresh_tokens" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"token_hash" varchar(255) NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"revoked_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "organization_members" ADD CONSTRAINT "organization_members_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "organization_members" ADD CONSTRAINT "organization_members_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_members" ADD CONSTRAINT "project_members_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_members" ADD CONSTRAINT "project_members_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "projects" ADD CONSTRAINT "projects_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "projects" ADD CONSTRAINT "projects_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sprints" ADD CONSTRAINT "sprints_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "issues" ADD CONSTRAINT "issues_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "issues" ADD CONSTRAINT "issues_reporter_id_users_id_fk" FOREIGN KEY ("reporter_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "issues" ADD CONSTRAINT "issues_assignee_id_users_id_fk" FOREIGN KEY ("assignee_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "issues" ADD CONSTRAINT "issues_sprint_id_sprints_id_fk" FOREIGN KEY ("sprint_id") REFERENCES "public"."sprints"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "issue_labels" ADD CONSTRAINT "issue_labels_issue_id_issues_id_fk" FOREIGN KEY ("issue_id") REFERENCES "public"."issues"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "issue_labels" ADD CONSTRAINT "issue_labels_label_id_labels_id_fk" FOREIGN KEY ("label_id") REFERENCES "public"."labels"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "labels" ADD CONSTRAINT "labels_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "comments" ADD CONSTRAINT "comments_issue_id_issues_id_fk" FOREIGN KEY ("issue_id") REFERENCES "public"."issues"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "comments" ADD CONSTRAINT "comments_author_id_users_id_fk" FOREIGN KEY ("author_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "attachments" ADD CONSTRAINT "attachments_issue_id_issues_id_fk" FOREIGN KEY ("issue_id") REFERENCES "public"."issues"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "attachments" ADD CONSTRAINT "attachments_uploaded_by_users_id_fk" FOREIGN KEY ("uploaded_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "activity_logs" ADD CONSTRAINT "activity_logs_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "activity_logs" ADD CONSTRAINT "activity_logs_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "issues_project_idx" ON "issues" USING btree ("project_id");--> statement-breakpoint
CREATE INDEX "issues_assignee_idx" ON "issues" USING btree ("assignee_id");--> statement-breakpoint
CREATE INDEX "issues_status_idx" ON "issues" USING btree ("status");--> statement-breakpoint
CREATE INDEX "issues_sprint_idx" ON "issues" USING btree ("sprint_id");--> statement-breakpoint
CREATE INDEX "comments_issue_idx" ON "comments" USING btree ("issue_id");--> statement-breakpoint
CREATE INDEX "notifications_user_idx" ON "notifications" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "activity_org_idx" ON "activity_logs" USING btree ("organization_id");--> statement-breakpoint
CREATE INDEX "activity_entity_idx" ON "activity_logs" USING btree ("entity_type","entity_id");--> statement-breakpoint
CREATE INDEX "refresh_tokens_user_idx" ON "refresh_tokens" USING btree ("user_id");