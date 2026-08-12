--音響戦士ギータス
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：丢弃1张手卡才能发动。从卡组把「音响战士 吉他手」以外的1只「音响战士」怪兽特殊召唤。
-- 【怪兽效果】
-- ①：这张卡召唤成功时，以自己墓地1只「音响战士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c12525049.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：丢弃1张手卡才能发动。从卡组把「音响战士 吉他手」以外的1只「音响战士」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12525049,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,12525049)
	e2:SetCost(c12525049.spcost)
	e2:SetTarget(c12525049.sptg)
	e2:SetOperation(c12525049.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功时，以自己墓地1只「音响战士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12525049,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetTarget(c12525049.target)
	e3:SetOperation(c12525049.operation)
	c:RegisterEffect(e3)
end
-- 设置灵摆效果的代价函数，检查是否可以丢弃手牌
function c12525049.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足丢弃手牌的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌的操作，丢弃1张可丢弃的手牌
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义灵摆效果中用于筛选特殊召唤怪兽的过滤函数
function c12525049.spfilter(c,e,tp)
	return c:IsSetCard(0x1066) and not c:IsCode(12525049) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置灵摆效果的目标函数，检查是否可以发动效果
function c12525049.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件，检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤的条件，检查卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c12525049.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 设置灵摆效果的发动函数
function c12525049.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位，若无则不发动效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组中选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c12525049.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义召唤成功时特殊召唤墓地怪兽的过滤函数
function c12525049.filter(c,e,tp)
	return c:IsSetCard(0x1066) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置召唤成功时的效果目标函数
function c12525049.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12525049.filter(chkc,e,tp) end
	-- 判断是否满足特殊召唤的条件，检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤的条件，检查墓地中是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c12525049.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的墓地怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从墓地中选择符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c12525049.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，提示将要特殊召唤1只墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置召唤成功时的效果发动函数
function c12525049.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
