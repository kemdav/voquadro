alter table "public"."users" add column "current_streak" integer not null default 0;

alter table "public"."users" add column "highest_streak" integer not null default 0;

alter table "public"."users" add column "level" integer not null default 1;


