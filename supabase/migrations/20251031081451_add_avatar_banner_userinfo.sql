alter table "public"."users" add column "MasteryLevel" integer not null default 1;

alter table "public"."users" add column "PubSpeakLvl" integer not null default 1;

alter table "public"."users" add column "bio" text;

alter table "public"."users" add column "current_streak" integer not null default 0;

alter table "public"."users" add column "highest_streak" integer not null default 0;

alter table "public"."users" add column "level" integer not null default 1;

alter table "public"."users" add column "profile_avatar_url" text;

alter table "public"."users" add column "profile_banner_url" text;


