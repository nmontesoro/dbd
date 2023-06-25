using System.Data;

namespace dbd.Data
{
    public class DapperContext
    {
        private static readonly string _connectionString =
            "Server=localhost;Database=Laboratorio;Uid=admin;Pwd=PwdDbd;";

        public static IDbConnection CreateConnection() => new
            System.Data.SqlClient.SqlConnection(_connectionString);
    }
}