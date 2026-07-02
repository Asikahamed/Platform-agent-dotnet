# ==================================================
# Build Stage
# ==================================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder

WORKDIR /src

# Copy project files first for dependency caching
COPY *.sln ./
COPY . .

# Restore dependencies
RUN dotnet restore

# Publish application
RUN dotnet publish \
    --configuration Release \
    --output /app/publish \
    --no-restore

# ==================================================
# Runtime Stage
# ==================================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

# Create non-root user
RUN groupadd --system dotnet && \
    useradd --system --gid dotnet dotnet

# Copy published application
COPY --from=builder /app/publish .

# Use non-root user
USER dotnet

EXPOSE 8080

ENV ASPNETCORE_URLS=http://+:8080

# Replace <APPLICATION_DLL> during asset generation
ENTRYPOINT ["dotnet", "<APPLICATION_DLL>"]