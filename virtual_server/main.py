import asyncio
import websockets
import msgpack

# Shared list of items
items = []

# Functions to handle different actions
async def get_items():
    return {"status": "success", "data": items}

async def add_item(item):
    if item:
        items.append(item)
        return {"status": "success", "message": f"Item '{item}' added."}
    return {"status": "error", "message": "Invalid item."}

async def remove_item(item):
    if item in items:
        items.remove(item)
        return {"status": "success", "message": f"Item '{item}' removed."}
    return {"status": "error", "message": f"Item '{item}' not found."}

async def edit_item(old_item, new_item):
    if old_item in items:
        index = items.index(old_item)
        items[index] = new_item
        return {"status": "success", "message": f"Item '{old_item}' updated to '{new_item}'."}
    return {"status": "error", "message": f"Item '{old_item}' not found."}

# Handler for incoming WebSocket connections
async def handle_connection(websocket):
    async for message in websocket:
        try:
            # Parse the incoming binary MessagePack message
            request = msgpack.unpackb(message)
            action = request.get("action")
            data = request.get("data", {})
            
            # Route the request based on the action
            if action == "get_items":
                response = await get_items()
            elif action == "add_item":
                item = data.get("item")
                response = await add_item(item)
            elif action == "remove_item":
                item = data.get("item")
                response = await remove_item(item)
            elif action == "edit_item":
                old_item = data.get("old_item")
                new_item = data.get("new_item")
                response = await edit_item(old_item, new_item)
            else:
                response = {"status": "error", "message": "Unknown action."}
        except Exception as e:
            response = {"status": "error", "message": str(e)}
        
        # Send the response as a MessagePack binary
        print(f"response: {response}")
        packed_response = msgpack.packb(response)
        await websocket.send(packed_response)

# Start the WebSocket server
async def main():
    async with websockets.serve(handle_connection, "localhost", 8765):
        print("WebSocket server started on ws://localhost:8765")
        await asyncio.Future()  # Run forever

# Run the server
if __name__ == "__main__":
    asyncio.run(main())
