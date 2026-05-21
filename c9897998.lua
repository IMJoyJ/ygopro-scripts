--ガスタ・コドル
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1只守备力1500以下的念动力族·风属性怪兽特殊召唤。
function c9897998.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1只守备力1500以下的念动力族·风属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9897998,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c9897998.condition)
	e1:SetTarget(c9897998.target)
	e1:SetOperation(c9897998.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身在战斗中，且自身作为攻击怪兽或被攻击怪兽，将对方怪兽战斗破坏并送去墓地
function c9897998.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	return c:IsRelateToBattle() and ((a==c and d:IsLocation(LOCATION_GRAVE) and d:IsType(TYPE_MONSTER))
		or (d==c and a:IsLocation(LOCATION_GRAVE) and a:IsType(TYPE_MONSTER)))
end
-- 过滤条件：守备力1500以下、念动力族、风属性且可以特殊召唤的怪兽
function c9897998.filter(c,e,tp)
	return c:IsDefenseBelow(1500) and c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查怪兽区域是否有空位，以及卡组中是否存在满足条件的怪兽，并设置特殊召唤的操作信息
function c9897998.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空余怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c9897998.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的怪兽在自己场上表侧表示特殊召唤
function c9897998.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足过滤条件的怪兽
	local g = Duel.SelectMatchingCard(tp,c9897998.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
