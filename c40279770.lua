--黒羽の導き
-- 效果：
-- 卡的效果让自己受到伤害时才能发动。从手卡把1只4星以下的名字带有「黑羽」的怪兽特殊召唤。
function c40279770.initial_effect(c)
	-- 卡的效果让自己受到伤害时才能发动。从手卡把1只4星以下的名字带有「黑羽」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c40279770.condition)
	e1:SetTarget(c40279770.target)
	e1:SetOperation(c40279770.activate)
	c:RegisterEffect(e1)
end
-- 判断受到伤害的玩家是发动者本人且伤害原因为卡的效果，即满足“卡的效果让自己受到伤害时”的发动条件。
function c40279770.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_EFFECT)~=0
end
-- 筛选手牌中满足条件的「黑羽」怪兽：4星以下、卡名含有「黑羽」字段，并且能够被特殊召唤。
function c40279770.filter(c,e,tp)
	return c:IsSetCard(0x33) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时进行合法性检查：自己主要怪兽区有空位，且手牌存在至少1只符合条件的「黑羽」怪兽。
function c40279770.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有空余区域可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足条件的「黑羽」怪兽（不取对象）。
		and Duel.IsExistingMatchingCard(c40279770.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 设置本次效果处理的信息：预定从手卡特殊召唤1只怪兽，用于连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时，若自己场上仍有空位，则从手牌选择1只符合条件的「黑羽」怪兽进行特殊召唤。
function c40279770.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区已没有空位，则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的提示，供玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中筛选并选择1只满足条件的「黑羽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c40279770.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
