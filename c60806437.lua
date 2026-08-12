--UFOタートル
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只攻击力1500以下的炎属性怪兽表侧攻击表示特殊召唤。
function c60806437.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只攻击力1500以下的炎属性怪兽表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60806437,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c60806437.condition)
	e1:SetTarget(c60806437.target)
	e1:SetOperation(c60806437.operation)
	c:RegisterEffect(e1)
end
-- 确认这张卡被送去墓地作为发动条件
function c60806437.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 过滤卡组中攻击力1500以下、炎属性且可以表侧攻击表示特殊召唤的怪兽
function c60806437.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动目标：检查己方怪兽区域是否有空位，且卡组中是否存在符合条件的怪兽
function c60806437.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有可以用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c60806437.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的怪兽表侧攻击表示特殊召唤
function c60806437.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时己方场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c60806437.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
