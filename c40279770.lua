--黒羽の導き
-- 效果：
-- 卡的效果让自己受到伤害时才能发动。从手卡把1只4星以下的名字带有「黑羽」的怪兽特殊召唤。
function c40279770.initial_effect(c)
	-- 创建效果，设置为发动时点，条件为受到伤害，目标为特殊召唤，效果处理为特殊召唤手牌中的黑羽怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c40279770.condition)
	e1:SetTarget(c40279770.target)
	e1:SetOperation(c40279770.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：伤害来源为使用者自身且伤害由效果造成
function c40279770.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_EFFECT)~=0
end
-- 过滤函数：筛选手牌中名字带有黑羽、等级4以下且可以被特殊召唤的怪兽
function c40279770.filter(c,e,tp)
	return c:IsSetCard(0x33) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的条件判断：确认场上是否有空位且手牌中存在满足条件的怪兽
function c40279770.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c40279770.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 设置连锁处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：检查是否有空位，若有则提示选择并特殊召唤符合条件的怪兽
function c40279770.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有空位则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c40279770.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
