SELECT b.title, g.description
FROM Books b
JOIN Genres g ON b.genre_code = g.code;