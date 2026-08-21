package wethinkcode.persistence;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Exercise 3.3
 */
public class Finder {

    private final Connection connection;

    /**
     * Create an instance of the Finder object using the provided database connection
     *
     * @param connection The JDBC connection to use
     */
    public Finder(Connection connection) {
        this.connection = connection;
    }

    /**
     * 3.3 (part 1) Complete this method
     * <p>
     * Finds all genres in the database
     *
     * @return a list of `Genre` objects
     * @throws SQLException the query failed
     */
    public List<Genre> findAllGenres() throws SQLException {
        String sql = "SELECT code, description FROM Genres";
        List<Genre> genres = new ArrayList<>();

        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {
                String code = rs.getString("code");
                String description = rs.getString("description");
                genres.add(new Genre(code, description));
            }
        }

        return genres;
    }

    /**
     * 3.3 (part 2) Complete this method
     * <p>
     * Finds all genres in the database that have specific substring in the description
     *
     * @param pattern The pattern to match
     * @return a list of `Genre` objects
     * @throws SQLException the query failed
     */
    public List<Genre> findGenresLike(String pattern) throws SQLException {
        String sql = "SELECT code, description FROM Genres WHERE description LIKE ?";
        List<Genre> genres = new ArrayList<>();

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, "%" + pattern + "%");

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    String code = rs.getString("code");
                    String description = rs.getString("description");
                    genres.add(new Genre(code, description));
                }
            }
        }

        return genres;
    }

    /**
     * 3.3 (part 3) Complete this method
     * <p>
     * Finds all books with their genres
     *
     * @return a list of `BookGenreView` objects
     * @throws SQLException the query failed
     */
    public List<BookGenreView> findBooksAndGenres() throws SQLException {
        String sql = """
            SELECT b.title, g.description 
            FROM Books b 
            JOIN Genres g ON b.genre_code = g.code
            """;
        List<BookGenreView> bookGenreViews = new ArrayList<>();

        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {
                String title = rs.getString("title");
                String description = rs.getString("description");
                bookGenreViews.add(new BookGenreView(title, description));
            }
        }

        return bookGenreViews;
    }

    /**
     * 3.3 (part 4) Complete this method
     * <p>
     * Finds the number of books in a genre
     *
     * @return the number of books in the genre
     * @throws SQLException the query failed
     */
    public int findNumberOfBooksInGenre(String genreCode) throws SQLException {
        String sql = """
            SELECT COUNT(*) as count 
            FROM Books b 
            JOIN Genres g ON b.genre_code = g.code 
            WHERE g.code = ?
            """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, genreCode);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }

        return 0;
    }
}
