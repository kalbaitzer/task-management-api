# Est�gio 1: Build (Compila��o)
# Usamos a imagem do SDK completo do .NET 9 para compilar a aplica��o
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /

# Copia os arquivos de projeto (.csproj) e o arquivo de solu��o (.sln) primeiro
COPY ["TaskManagementAPI.API/TaskManagementAPI.API.csproj", "TaskManagementAPI.API/"]
COPY ["TaskManagementAPI.Application/TaskManagementAPI.Application.csproj", "TaskManagementAPI.Application/"]
COPY ["TaskManagementAPI.Core/TaskManagementAPI.Core.csproj", "TaskManagementAPI.Core/"]
COPY ["TaskManagementAPI.Infrastructure/TaskManagementAPI.Infrastructure.csproj", "TaskManagementAPI.Infrastructure/"]
COPY ["TaskManagementAPI.sln", "."]

# Restaura as depend�ncias NuGet (isso � feito antes para aproveitar o cache do Docker)
RUN dotnet restore TaskManagementAPI.sln

# Copia todo o resto do c�digo fonte
COPY . .

# Publica a aplica��o em modo de Release, otimizada para produ��o
WORKDIR "TaskManagementAPI.API"
RUN dotnet publish "TaskManagementAPI.API.csproj" -c Release -o /app/publish

# Est�gio 2: Final (Execu��o)
# Usamos a imagem do ASP.NET, que � menor
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Copia apenas os arquivos publicados do est�gio de build
COPY --from=build /app/publish .

# Define o ponto de entrada, o comando que ser� executado quando o cont�iner iniciar
ENTRYPOINT ["dotnet", "TaskManagementAPI.API.dll"]