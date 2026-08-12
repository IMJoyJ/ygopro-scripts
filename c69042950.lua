--バグ・ロード
-- 效果：
-- 双方可以把和自己场上表侧表示存在的1只4星以下的怪兽相同等级的1只怪兽从手卡特殊召唤。
function c69042950.initial_effect(c)
	-- 双方可以把和自己场上表侧表示存在的1只4星以下的怪兽相同等级的1只怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c69042950.target)
	e1:SetOperation(c69042950.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且等级等于指定等级的怪兽
function c69042950.mfilter(c,clv)
	return c:IsFaceup() and c:IsLevel(clv)
end
-- 过滤条件：场上表侧表示的4星以下的怪兽
function c69042950.mfilter2(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- 过滤条件：手卡中可以特殊召唤的4星以下怪兽，且自己场上存在与之相同等级的表侧表示怪兽
function c69042950.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在与该手卡怪兽等级相同的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c69042950.mfilter,tp,LOCATION_MZONE,0,1,nil,c:GetLevel())
end
-- 效果发动的目标确认与可行性检查
function c69042950.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c69042950.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检查对方场上是否存在4星以下的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c69042950.mfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置特殊召唤的操作信息，表示从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数
function c69042950.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示自己选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让自己从手卡选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c69042950.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()~=0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上（放入特殊召唤准备步骤）
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 检查对方场上是否有可用的怪兽区域
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方手卡中是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c69042950.spfilter,1-tp,LOCATION_HAND,0,1,nil,e,1-tp)
		-- 询问对方玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(1-tp,aux.Stringid(69042950,0)) then  --"是否把怪兽从手卡特殊召唤？"
		-- 提示对方选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让对方从手卡选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(1-tp,c69042950.spfilter,1-tp,LOCATION_HAND,0,1,1,nil,e,1-tp)
		if g:GetCount()~=0 then
			-- 将选中的怪兽以表侧表示特殊召唤到对方场上（放入特殊召唤准备步骤）
			Duel.SpecialSummonStep(g:GetFirst(),0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
