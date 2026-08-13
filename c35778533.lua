--白き森にはいるべからず
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有6星以上的幻想魔族或魔法师族的怪兽存在的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建并注册此卡的两个效果：①效果为发动时选择对方场上1张卡破坏；②效果为这张卡作为怪兽效果发动的代价被送去墓地时，将自身盖放到自己场上。
function s.initial_effect(c)
	-- ①：自己场上有6星以上的幻想魔族或魔法师族的怪兽存在的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数：卡需为表侧表示、等级6以上，且种族为魔法师族或幻想魔族。
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(6) and c:IsRace(RACE_SPELLCASTER+RACE_ILLUSION)
end
-- ①效果的发动条件：自己场上存在满足s.cfilter的怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示且等级6以上的魔法师族或幻想魔族怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动目标：校验对象为对方场上的卡；发动时确认存在可取对象后，提示玩家从对方场上选择1张卡，并登记破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 效果发动时检查对方场上是否存在可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要破坏的卡”的提示消息，并缓存选择用途。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张卡作为效果的对象（同时将该卡设为当前连锁的对象）。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息为破坏1张卡，目标为已选对象，用于后续连锁判定（如星尘龙）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：取得对象卡，若该卡仍与效果关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡是作为怪兽效果的发动代价被送去墓地的，且该怪兽效果属于发动效果。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动目标：自己可以盖放时才能发动，并登记操作信息为涉及离开墓地。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 登记操作信息：此卡将离开墓地（用于检测王家长眠之谷等影响墓地卡移动的效果）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：若自身仍与效果关联，则将此卡盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡仍与效果关联（未被除外或转移等），满足则将其盖放到自己场上。
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
