--偽りの種
-- 效果：
-- 从手卡把1只2星以下的植物族怪兽特殊召唤。
function c18752938.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点，可以自由连锁，目标函数为c18752938.target，效果处理函数为c18752938.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18752938.target)
	e1:SetOperation(c18752938.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手牌中等级2以下且为植物族的怪兽，且可以被特殊召唤
function c18752938.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的判断函数，检查是否满足发动条件
function c18752938.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c18752938.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行特殊召唤操作
function c18752938.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的怪兽区域，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c18752938.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
