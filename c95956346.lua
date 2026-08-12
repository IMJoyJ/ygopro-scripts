--シャインエンジェル
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只攻击力1500以下的光属性怪兽表侧攻击表示特殊召唤。
function c95956346.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只攻击力1500以下的光属性怪兽表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95956346,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c95956346.condition)
	e1:SetTarget(c95956346.target)
	e1:SetOperation(c95956346.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否在墓地（确认被送去墓地）
function c95956346.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 过滤卡组中攻击力1500以下、光属性且可以表侧攻击表示特殊召唤的怪兽
function c95956346.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动的目标检查，确认自身怪兽区域有空位且卡组中存在符合条件的怪兽
function c95956346.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查当前玩家场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在效果发动阶段，检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c95956346.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息，声明此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择符合条件的怪兽并特殊召唤到场上
function c95956346.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果当前玩家场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c95956346.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到当前玩家的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
