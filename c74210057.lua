--テクスチェンジャー
-- 效果：
-- ①：1回合1次，自己怪兽被选择作为攻击对象时才能发动。那次攻击无效。那之后，从自己的手卡·卡组·墓地选1只电子界族通常怪兽特殊召唤。
function c74210057.initial_effect(c)
	-- ①：1回合1次，自己怪兽被选择作为攻击对象时才能发动。那次攻击无效。那之后，从自己的手卡·卡组·墓地选1只电子界族通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c74210057.condition)
	e1:SetTarget(c74210057.target)
	e1:SetOperation(c74210057.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：自己怪兽被选择作为攻击对象时
function c74210057.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前的攻击对象是否存在，且该攻击对象是否由自己控制
	return Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp)
end
-- 过滤条件：电子界族通常怪兽，且可以被特殊召唤
function c74210057.filter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的检测与目标设置
function c74210057.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡、卡组、墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c74210057.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，声明此效果包含从手卡、卡组、墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：无效攻击，并从手卡、卡组、墓地特殊召唤1只电子界族通常怪兽
function c74210057.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效攻击，若无效失败或此时自己场上没有空余怪兽区域，则结束效果处理
	if not Duel.NegateAttack() or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡、卡组、墓地中选择1只满足条件的电子界族通常怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c74210057.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使前后的“无效攻击”与“特殊召唤”不视为同时处理
		Duel.BreakEffect()
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
