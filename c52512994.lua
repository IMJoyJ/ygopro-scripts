--火車
-- 效果：
-- 这张卡不能通常召唤。自己场上的不死族怪兽是2只以上的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。这张卡以外的场上的怪兽全部回到持有者卡组。原本种族是不死族的表侧表示怪兽回到卡组的场合，这张卡的攻击力变成那些怪兽数量×1000。
function c52512994.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法通常召唤，必须满足特殊召唤条件。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 自己场上的不死族怪兽是2只以上的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c52512994.spcon)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功的场合发动。这张卡以外的场上的怪兽全部回到持有者卡组。原本种族是不死族的表侧表示怪兽回到卡组的场合，这张卡的攻击力变成那些怪兽数量×1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52512994,0))  --"返回卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c52512994.tdtg)
	e3:SetOperation(c52512994.tdop)
	c:RegisterEffect(e3)
end
-- 筛选场上正面表示的不死族怪兽。
function c52512994.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 检查玩家场上是否有至少2只正面表示的不死族怪兽，并且有可用的召唤区域。
function c52512994.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家是否有可用的召唤区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查玩家场上是否存在至少2只正面表示的不死族怪兽。
		and Duel.IsExistingMatchingCard(c52512994.spfilter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end
-- 设置效果发动时的目标为场上所有可以送回卡组的怪兽。
function c52512994.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有可以送回卡组的怪兽作为目标。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 将目标怪兽数量和类型记录到连锁操作信息中。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 筛选从卡组或额外卡组返回且原本为正面表示的不死族怪兽。
function c52512994.rfilter(c)
	return c:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsRace(RACE_ZOMBIE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 执行效果处理：将场上所有怪兽送回卡组，并根据返回的不死族怪兽数量提升攻击力。
function c52512994.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有可以送回卡组的怪兽（排除自身）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将目标怪兽全部送回卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 统计实际被送回卡组的不死族怪兽数量。
	local rt=Duel.GetOperatedGroup():FilterCount(c52512994.rfilter,nil)
	if rt>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将该卡的攻击力临时提升为返回的不死族怪兽数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(rt*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
