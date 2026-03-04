--ガトムズの緊急指令
-- 效果：
-- ①：场上有「X-剑士」怪兽存在的场合，以自己·对方的墓地的「X-剑士」怪兽合计2只为对象才能发动。那2只怪兽在自己场上特殊召唤。
function c13504844.initial_effect(c)
	-- 效果原文内容：①：场上有「X-剑士」怪兽存在的场合，以自己·对方的墓地的「X-剑士」怪兽合计2只为对象才能发动。那2只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c13504844.condition)
	e1:SetTarget(c13504844.target)
	e1:SetOperation(c13504844.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在表侧表示的「X-剑士」怪兽
function c13504844.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 条件函数，用于判断是否满足发动此卡的条件
function c13504844.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只表侧表示的「X-剑士」怪兽
	return Duel.IsExistingMatchingCard(c13504844.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤函数，用于检查墓地中的「X-剑士」怪兽是否可以被特殊召唤
function c13504844.filter(c,e,tp)
	return c:IsSetCard(0x100d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数，用于选择2只墓地中的「X-剑士」怪兽作为效果对象
function c13504844.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c13504844.filter(chkc,e,tp) end
	-- 检查是否满足发动条件，包括未被「王家长眠之谷」等效果影响
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有至少2个可用区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己和对方墓地合计是否存在至少2只「X-剑士」怪兽
		and Duel.IsExistingTarget(c13504844.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择2只满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c13504844.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil,e,tp)
	-- 设置效果处理时要特殊召唤的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理函数，执行将选中的怪兽特殊召唤到自己场上的操作
function c13504844.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否被「王家长眠之谷」等效果影响
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上是否有至少2个可用区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取当前连锁中已选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()~=2 then return end
	-- 将符合条件的卡组特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
