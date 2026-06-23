--電池メン－業務用
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只名字带有「电池人」的怪兽从游戏中除外的场合才能特殊召唤。1回合1次，把自己墓地1只雷族怪兽从游戏中除外才能发动。选择场上1只怪兽和1张魔法·陷阱卡破坏。
function c19441018.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己墓地2只名字带有「电池人」的怪兽从游戏中除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19441018.spcon)
	e1:SetTarget(c19441018.sptg)
	e1:SetOperation(c19441018.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为无法无效且无法复制的特殊召唤条件效果，且该效果始终返回假值，使该卡无法通过通常方式召唤。
	e2:SetValue(aux.FALSE)
	c:RegisterEffect(e2)
	-- 1回合1次，把自己墓地1只雷族怪兽从游戏中除外才能发动。选择场上1只怪兽和1张魔法·陷阱卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19441018,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c19441018.descost)
	e3:SetTarget(c19441018.destg)
	e3:SetOperation(c19441018.desop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的墓地「电池人」怪兽，用于特殊召唤的条件判断。
function c19441018.spfilter(c)
	return c:IsSetCard(0x28) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件：场上是否有空位且自己墓地是否有2只以上「电池人」怪兽。
function c19441018.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否有2只以上名字带有「电池人」的怪兽。
		and Duel.IsExistingMatchingCard(c19441018.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 选择并设置要除外的2只「电池人」怪兽。
function c19441018.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足条件的墓地「电池人」怪兽。
	local g=Duel.GetMatchingGroup(c19441018.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时将选中的怪兽从游戏中除外。
function c19441018.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽从游戏中除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤满足条件的墓地雷族怪兽，用于发动效果的代价。
function c19441018.costfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足发动条件：自己墓地是否有1只以上雷族怪兽。
function c19441018.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：自己墓地是否有1只以上雷族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19441018.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的1只雷族怪兽。
	local g=Duel.SelectMatchingCard(tp,c19441018.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的雷族怪兽从游戏中除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 判断场上是否存在可以被破坏的怪兽。
function c19441018.filter1(c)
	-- 判断场上是否存在魔法·陷阱卡。
	return Duel.IsExistingTarget(c19441018.filter2,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 判断是否为魔法或陷阱卡。
function c19441018.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择要破坏的怪兽和魔法·陷阱卡。
function c19441018.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足发动条件：场上是否有怪兽可被选择。
	if chk==0 then return Duel.IsExistingTarget(c19441018.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽。
	local g1=Duel.SelectTarget(tp,c19441018.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡。
	local g2=Duel.SelectTarget(tp,c19441018.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 设置操作信息，确定要破坏的卡数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 执行破坏效果，将选中的卡破坏。
function c19441018.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local dg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
