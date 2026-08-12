--究極宝玉神 レインボー・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。自己的场上·墓地是「宝玉兽」卡7种类存在的场合才能特殊召唤。这张卡特殊召唤的回合，这张卡的①②的效果不能发动。
-- ①：把自己场上的表侧表示的「宝玉兽」怪兽全部送去墓地才能发动。这张卡的攻击力上升送去墓地的怪兽数量×1000。这个效果在对方回合也能发动。
-- ②：从自己墓地把「宝玉兽」怪兽全部除外才能发动。场上的卡全部回到持有者卡组。
function c79856792.initial_effect(c)
	c:EnableReviveLimit()
	-- 自己的场上·墓地是「宝玉兽」卡7种类存在的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c79856792.spcon)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- ①：把自己场上的表侧表示的「宝玉兽」怪兽全部送去墓地才能发动。这张卡的攻击力上升送去墓地的怪兽数量×1000。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetDescription(aux.Stringid(79856792,0))  --"攻击力上升"
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c79856792.atcon)
	e3:SetCost(c79856792.atcost)
	e3:SetOperation(c79856792.atop)
	c:RegisterEffect(e3)
	-- ②：从自己墓地把「宝玉兽」怪兽全部除外才能发动。场上的卡全部回到持有者卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetDescription(aux.Stringid(79856792,1))  --"场上的卡全部回到持有者卡组"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c79856792.tdcon)
	e4:SetCost(c79856792.tdcost)
	e4:SetTarget(c79856792.tdtg)
	e4:SetOperation(c79856792.tdop)
	c:RegisterEffect(e4)
	-- 这张卡特殊召唤的回合，这张卡的①②的效果不能发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetOperation(c79856792.spop)
	c:RegisterEffect(e5)
end
-- 过滤条件：场上表侧表示或墓地的「宝玉兽」卡
function c79856792.spfilter(c)
	return c:IsSetCard(0x1034) and (not c:IsOnField() or c:IsFaceup())
end
-- 特殊召唤规则的条件：自己场上·墓地存在7种「宝玉兽」卡
function c79856792.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 获取自己场上及墓地的所有「宝玉兽」卡
	local g=Duel.GetMatchingGroup(c79856792.spfilter,c:GetControler(),LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)==7
end
-- 特殊召唤成功时，给自身注册一个持续到回合结束的标记（用于限制①②效果的发动）
function c79856792.spop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(79856792,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end
-- 效果①的发动条件：非伤害计算后，且本回合未进行过特殊召唤
function c79856792.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前不处于伤害计算后，且自身没有特殊召唤回合的标记
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():GetFlagEffect(79856792)==0
end
-- 过滤条件：自己场上表侧表示且可以送去墓地作为发动代价的「宝玉兽」怪兽
function c79856792.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价：将自己场上表侧表示的「宝玉兽」怪兽全部送去墓地，并记录送去墓地的数量
function c79856792.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上是否存在至少1只满足条件的「宝玉兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79856792.afilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有满足条件的「宝玉兽」怪兽
	local g=Duel.GetMatchingGroup(c79856792.afilter,tp,LOCATION_MZONE,0,nil)
	-- 将这些怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 效果①的效果处理：使这张卡的攻击力上升送去墓地的怪兽数量×1000
function c79856792.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升送去墓地的怪兽数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel()*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：本回合未进行过特殊召唤
function c79856792.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(79856792)==0
end
-- 过滤条件：自己墓地可以除外作为发动代价的「宝玉兽」怪兽
function c79856792.cfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价：将自己墓地的「宝玉兽」怪兽全部除外
function c79856792.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己墓地是否存在至少1只「宝玉兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79856792.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取自己墓地所有的「宝玉兽」怪兽
	local g=Duel.GetMatchingGroup(c79856792.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 将这些怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备：确认场上是否存在可以回到卡组的卡，并设置回到卡组的操作信息
function c79856792.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认场上是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取双方场上所有可以回到卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置将场上所有这些卡回到卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的效果处理：将场上的卡全部回到持有者卡组
function c79856792.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有可以回到卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将这些卡全部送回持有者的卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
