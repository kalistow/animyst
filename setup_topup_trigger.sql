-- Function to handle adding gems when topup is marked complete
CREATE OR REPLACE FUNCTION public.handle_topup_completion()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if status is changed to 'complete' (case insensitive)
  IF LOWER(NEW.status) = 'complete' AND LOWER(OLD.status) != 'complete' THEN
    
    -- Update the user's gems in profiles table
    UPDATE public.profiles
    SET gems = gems + NEW.gems_amount
    WHERE id = NEW.user_id;
    
    -- Optional: You could log this or do other cleanup here
  END IF;
  return NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to watch for updates on topup_requests
DROP TRIGGER IF EXISTS on_topup_complete ON public.topup_requests;

CREATE TRIGGER on_topup_complete
AFTER UPDATE ON public.topup_requests
FOR EACH ROW
EXECUTE FUNCTION public.handle_topup_completion();
