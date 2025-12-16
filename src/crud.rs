use anyhow::Result;
use directories::ProjectDirs;
use sqlx::SqlitePool;

use sqlx::sqlite::{SqliteConnectOptions, SqlitePoolOptions};

use std::path::PathBuf;
use std::str::FromStr;

use anyhow::anyhow;

pub struct DB {
    pool: SqlitePool,
}

impl DB {
    pub async fn new() -> Result<Self> {
        let proj_dirs = ProjectDirs::from("", "", "repeat")
            .ok_or_else(|| anyhow!("Could not determine project directory"))?;
        let data_dir = proj_dirs.data_dir();
        std::fs::create_dir_all(data_dir)
            .map_err(|e| anyhow!("Failed to create data directory: {}", e))?;

        let db_path: PathBuf = data_dir.join("cards.db");
        let db_url = format!("sqlite://{}", db_path.to_string_lossy());
        dbg!(&db_url);
        let options =
            SqliteConnectOptions::from_str(&db_path.to_string_lossy())?.create_if_missing(true);
        let pool = SqlitePoolOptions::new()
            .max_connections(5)
            .connect_with(options)
            .await?;
        let table_exists = probe_schema_exists(&pool).await;
        if let Ok(false) = table_exists {
            sqlx::query(include_str!("schema.sql"))
                .execute(&pool)
                .await?;
        }

        Ok(Self { pool })
    }
}

async fn probe_schema_exists(pool: &SqlitePool) -> Result<bool, sqlx::Error> {
    let sql = "select count(*) from sqlite_master where type='table' AND name=?;";

    let count: (i64,) = sqlx::query_as(sql).bind("cards").fetch_one(pool).await?;
    Ok(count.0 > 0)
}
