--フォトン・リード
-- 效果：
-- 从手卡把1只4星以下的光属性怪兽表侧攻击表示特殊召唤。
function c35848254.initial_effect(c)
	-- 从手卡把1只4星以下的光属性怪兽表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35848254.target)
	e1:SetOperation(c35848254.activate)
	c:RegisterEffect(e1)
end
-- 定义可特殊召唤的怪兽条件：等级4以下、光属性，且能够以表侧攻击表示被效果特殊召唤。
function c35848254.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动时点检查：自己主要怪兽区有空位，且手牌中存在符合条件的怪兽。
function c35848254.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否还有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c35848254.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果涉及从手牌特殊召唤1只怪兽，用于时点与连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若主要怪兽区有空位，则选择手牌中符合条件的1只怪兽并表侧攻击表示特殊召唤。
function c35848254.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有空位，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中选择1只满足条件的怪兽（4星以下光属性且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c35848254.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
