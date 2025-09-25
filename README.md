# Voquadro

This Flutter project is an AI-powered public speaking co-pilot that analyzes your practice speeches to provide personalized feedback and a motivating progression system to help you improve.

## Table of Contents

- [Voquadro](#voquadro)
  - [Table of Contents](#table-of-contents)
  - [Development Workflow](#development-workflow)
    - [Branching Strategy](#branching-strategy)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
  - [Local Development](#local-development)
    - [Setting Up Environment Variables](#setting-up-environment-variables)
    - [Running the Local Backend](#running-the-local-backend)
    - [Running the Frontend App](#running-the-frontend-app)
  - [Database Migrations](#database-migrations)
    - [Syncing Your Local Database](#syncing-your-local-database)
    - [Creating a New Migration](#creating-a-new-migration)
    - [Committing and Sharing Migrations](#committing-and-sharing-migrations)
  - [Stopping the Local Environment](#stopping-the-local-environment)

## Development Workflow

This project follows a structured Git workflow to ensure code quality and a stable production environment.

### Branching Strategy

We use a Gitflow-like branching model.

- **`main`**: This branch contains production-ready code. Direct pushes are disabled. Code is only merged into `main` from `develop` during a release.
- **`develop`**: This is the primary development branch. All feature branches are created from `develop` and merged back into it.
- **Feature branches**: All new features and bug fixes are developed on their own branches, branched from `develop`.

Follow this naming convention for your branches:

- **Features**: `feature/short-feature-description` (e.g., `feature/user-authentication`)
- **Bug Fixes**: `fix/short-bug-description` (e.g., `fix/login-form-validation`)

## Getting Started

Follow these steps to set up your local development environment.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (ensure `flutter doctor` reports no issues)
- [Git](https://git-scm.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (must be running for the Supabase CLI to work)

### Setup

1. **Install the Supabase CLI:** Follow the official guide to install it on your machine: [Supabase CLI Docs](https://supabase.com/docs/guides/cli).

2. **Clone the repository:**

   ```bash
   git clone https://github.com/your-repo/project-name.git
   cd project-name
   ```

3. **Install Project Dependencies:**

   ```bash
   flutter pub get
   ```

## Local Development

### Setting Up Environment Variables

Environment variables are used to store sensitive information like API keys. We use a `.env.local` file for local development, which is ignored by Git. This project uses the `flutter_dotenv` package to manage them.

1. Create a local environment file by copying the example file.
   **For Windows (in Command Prompt):**

   ```powershell
   copy .env.example .env.local
   ```

   **For Mac/Linux:**

   ```bash
   cp .env.example .env.local
   ```

2. Ensure your `pubspec.yaml` file is configured to include the `.env.local` file as an asset:

   ```yaml
   flutter:
     assets:
       - .env.local
   ```

   _Note: Remember to run `flutter pub get` again if you modify `pubspec.yaml`._

3. The new `.env.local` file will be populated with the correct credentials in the next step.

### Running the Local Backend

We use the Supabase CLI to run the entire backend stack (database, auth, storage) on your machine.

1. **Start all Supabase services:**

   ````bash
   supabase start
   ```    *Note: The first time you run this, it will download the necessary Docker images, which may take a few minutes.*

   ````

2. Once successful, the CLI will output your local credentials and service URLs:

   ```plaintext
   Supabase local development setup initiated.

   API URL: http://localhost:54321
   DB URL: postgresql://postgres:postgres@localhost:54322/postgres
   Studio URL: http://localhost:54323
   Inbucket URL: http://localhost:54324
   anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. **Update your `.env.local` file:** Copy and paste the `API URL` and `anon key` from the terminal output into your `.env.local` file.

   ```.env.local
   SUPABASE_URL="http://localhost:54321"
   SUPABASE_ANON_KEY="your-local-anon-key-from-cli"
   ```

### Running the Frontend App

Once the backend is running, you can start the Flutter application on your desired device or simulator.

```bash
flutter run
```

Your `main.dart` file should be configured to load these environment variables before initializing Supabase.

## Database Migrations

We manage all database schema changes through migration files. **Do not make schema changes using the Studio UI on cloud environments (Staging/Prod)**. You can, however, use the local Studio UI to generate SQL, which you can then copy into a migration file.

### Syncing Your Local Database

When you pull new changes from a teammate that include new migration files, your local database schema will be out of date. To sync it, run the reset command.

```bash
supabase db reset
```

This command **wipes your local database clean** and re-runs all migration files from the `supabase/migrations` folder in chronological order, ensuring your local schema matches the latest version in the codebase.

### Creating a New Migration

When you need to make a schema change (e.g., create a table, add a column, set up a policy):

1. **Make your changes in the local Supabase Studio** (`http://localhost:54323`). You can use the UI to design your table and policies.

2. **Generate a new migration file:** Once you are happy with your changes, create a new migration file to record the SQL. Give it a descriptive name.

   ```bash
   supabase migration new <your_descriptive_name>
   ```

   For example:

   ```bash
   supabase migration new create_profiles_table_with_rls
   ```

   This command creates a new, empty SQL file in the `supabase/migrations` directory.

3. **Get the SQL for your changes:** In the Supabase Studio, you can often find the SQL equivalent of your UI actions. For table creation, you can use the "SQL" button in the table editor.

4. **Add the SQL to your migration file:** Paste the generated SQL into the new migration file you created. It is critical to ensure this file contains all the necessary changes.

5. **Apply the migration locally:** To confirm your migration file works correctly, reset your local database. This will apply the new migration you just created.

   ```bash
   supabase db reset
   ```

### Committing and Sharing Migrations

Once you have created and tested your migration file, it's ready to be shared with the team.

1. **Add the migration file to Git:**

   ```bash
   git add supabase/migrations
   ```

2. **Commit your changes** along with any related application code.

   ```bash
   git commit -m "feat: create profiles table and setup RLS policies"
   ```

3. **Push your branch** and create a Pull Request. Your teammates can now pull your changes and update their own local databases.

## Stopping the Local Environment

When you are finished with your development session, you can stop the local Supabase services to free up system resources.

```bash
supabase stop
```
