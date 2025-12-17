use crate::crud::DB;
use crate::drill::register_all_cards;

use anyhow::Result;

pub async fn run(db: &DB, paths: Vec<String>) -> Result<usize> {
    let card_hash = register_all_cards(db, paths).await?;
    let count = card_hash.len();
    eprintln!("Found {} unique cards and registered them to the DB", count);
    Ok(count)
}
