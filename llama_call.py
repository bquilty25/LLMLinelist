from openai import OpenAI

# Point to the local server
client = OpenAI(base_url="http://localhost:1234/v1", api_key="not-needed")

# Open the file in read mode ('r')
with open('system_prompt.txt', 'r') as file:
    # Read the entire contents of the file
    system_prompt = file.read()

def create_response(prompt):
  completion = client.chat.completions.create(
    model="local-model", # this field is currently unused
    messages=[
      {"role": "system", "content": system_prompt},
      {"role": "user", "content": prompt + "Output:\n"}
    ],
    stop = ["\n\n"],
    temperature=0,
  )

  return completion.choices[0].message.content


