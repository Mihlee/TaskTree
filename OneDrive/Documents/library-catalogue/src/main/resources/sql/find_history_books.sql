SELECT COUNT(*) FROM Books b
JOIN Genres g ON b.genre_code = g.code
WHERE g.description = 'History';