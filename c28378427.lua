--ダメージ・コンデンサー
-- 效果：
-- 自己受到战斗伤害时，丢弃1张手卡才能发动。持有那个时候受到的伤害数值以下的攻击力的1只怪兽从卡组攻击表示特殊召唤。
function c28378427.initial_effect(c)
	-- 创建效果并设置其分类为特殊召唤、类型为发动、触发时点为造成战斗伤害、条件函数为condition、代价函数为cost、目标函数为target、发动函数为activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c28378427.condition)
	e1:SetCost(c28378427.cost)
	e1:SetTarget(c28378427.target)
	e1:SetOperation(c28378427.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：自己受到战斗伤害时
function c28378427.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 效果发动的代价：丢弃1张手卡
function c28378427.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检查卡是否满足攻击力低于等于伤害值且可以特殊召唤
function c28378427.filter(c,e,tp,dam)
	return c:IsAttackBelow(dam) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 设置效果的目标：检查场上是否有满足条件的怪兽可以特殊召唤
function c28378427.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c28378427.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ev) end
	-- 设置操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动的处理：选择并特殊召唤满足条件的怪兽
function c28378427.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c28378427.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ev)
	if g:GetCount()~=0 then
		-- 将选中的怪兽以攻击表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
