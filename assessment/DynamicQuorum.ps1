$dc = (get-cluster).DynamicQuorum
if ($dc -eq 0)
{
  (get-cluster).DynamicQuorum=1
}
