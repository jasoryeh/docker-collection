# Disposable Minecraft Server
Fires up a really quick Minecraft server.

## Configuration
`JARFILE_URL`: Where to download the Minecraft server jarfile from. Defaults to PaperMC latest.
`JAVA_VERSION`: Version of Java to use (currently avaialble in default image: 8, 17)
`JAVA_CMD`: The path of the Java executable if using another executable/version.
`TUNNEL_SERVER_AT`: If using a STUN(jasoryeh/stun) or a regular SSH server for tunneling this server out, specify the IP address here (without port).
`TUNNEL_SERVER_PORT`: Port of the STUN or SSH server.
