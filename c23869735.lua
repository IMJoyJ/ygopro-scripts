--化石発掘
-- 效果：
-- ①：丢弃1张手卡，以自己墓地1只恐龙族怪兽为对象才能把这张卡发动。那只恐龙族怪兽特殊召唤。
-- ②：这张卡的①的效果特殊召唤的怪兽只要这张卡在魔法与陷阱区域存在效果无效化，这张卡从场上离开时破坏。那只怪兽破坏时这张卡破坏。
function c23869735.initial_effect(c)
	-- ①：丢弃1张手卡，以自己墓地1只恐龙族怪兽为对象才能把这张卡发动。那只恐龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c23869735.cost)
	e1:SetTarget(c23869735.target)
	e1:SetOperation(c23869735.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤的怪兽只要这张卡在魔法与陷阱区域存在效果无效化，这张卡从场上离开时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c23869735.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果特殊召唤的怪兽只要这张卡在魔法与陷阱区域存在效果无效化，这张卡从场上离开时破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c23869735.descon2)
	e3:SetOperation(c23869735.desop2)
	c:RegisterEffect(e3)
	-- ②：这张卡的①的效果特殊召唤的怪兽只要这张卡在魔法与陷阱区域存在效果无效化，这张卡从场上离开时破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
end
-- 丢弃1张手卡作为发动代价
function c23869735.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选墓地中的恐龙族怪兽
function c23869735.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标的条件
function c23869735.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23869735.filter(chkc,e,tp) end
	-- 检查场上是否有特殊召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在符合条件的恐龙族怪兽
		and Duel.IsExistingTarget(c23869735.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c23869735.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c23869735.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且为恐龙族并进行特殊召唤
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DINOSAUR) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 当卡片离开场时，若其目标怪兽在场则将其破坏
function c23869735.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 当目标怪兽因破坏离开场时，将此卡破坏
function c23869735.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 将此卡破坏
function c23869735.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
