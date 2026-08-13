--差し戻し
-- 效果：
-- 对方把墓地的卡加入手卡时才能发动。对方让加入手卡的那1张卡回到卡组。
function c47247413.initial_effect(c)
	-- 对方把墓地的卡加入手卡时才能发动。对方让加入手卡的那1张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c47247413.condition)
	e1:SetTarget(c47247413.target)
	e1:SetOperation(c47247413.activate)
	c:RegisterEffect(e1)
end
-- 筛选“加入手卡的卡”中，之前位于墓地、且当前控制者为对手、并且与效果e仍有关联的卡。
function c47247413.filter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsControler(tp) and (not e or c:IsRelateToEffect(e))
end
-- 发动条件判定：检查本次加入手卡的卡组（eg）中是否存在至少1张“之前位于墓地且由对方控制的卡”，即对手把墓地的卡加入手卡时才能发动。
function c47247413.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47247413.filter,1,nil,nil,1-tp)
end
-- 发动时的处理：允许发动；将本次加入手卡的卡组设为对象并登记操作信息，表示效果处理时会使1张卡回到卡组。
function c47247413.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次加入手卡的卡组全部设为当前连锁的对象，建立与效果的关联，以便后续判断哪些卡仍在可处理范围内。
	Duel.SetTargetCard(eg)
	-- 登记操作信息：本效果属于回卡组效果，预计处理对象为eg中的1张卡，用于供系统和其他卡（如星尘龙等）进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
end
-- 效果处理：从加入手卡的卡中筛选出符合条件的卡；若存在，则由对手选择其中1张，给发动者确认后，将其送回卡组并洗牌。
function c47247413.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c47247413.filter,nil,e,1-tp)
	if g:GetCount()==0 then return end
	-- 向对手发送选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local rg=g:Select(1-tp,1,1,nil)
	-- 让发动者确认对手选择返回卡组的那1张卡。
	Duel.ConfirmCards(tp,rg)
	-- 将选中的卡以效果原因送回其持有者的卡组，并执行洗牌。
	Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
