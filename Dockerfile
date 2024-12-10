FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080




FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG Build_CONFIGURATION=Release
WORKDIR /src
COPY ["DataAccess/DataAccess.csproj","DataAccess/"]
COPY ["Bussiness/Bussiness.csproj","Bussiness/"]
COPY ["Presentation/Presentation.csproj", "Presentation/"]
RUN dotnet restore "Presentation/Presentation.csproj"

COPY . .
WORKDIR "/src/Presentation"
RUN dotnet build "Presentation.csproj" -c $Build_CONFIGURATION -o /app/build



FROM build AS publish
ARG Build_CONFIGURATION=Release
RUN dotnet publish "Presentation.csproj" -c $Build_CONFIGURATION -o /app/publish /p:UseAppHost=false


FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT [ "dotnet","Presentation.dll"]
HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1