--巨大ネズミ
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的地属性怪兽攻击表示特殊召唤。
function c97017120.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的地属性怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97017120,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c97017120.condition)
	e1:SetTarget(c97017120.target)
	e1:SetOperation(c97017120.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否在墓地（确认被送去墓地）
function c97017120.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 过滤卡组中攻击力1500以下的地属性且能以表侧攻击表示特殊召唤的怪兽
function c97017120.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动阶段：检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽，并设置操作信息
function c97017120.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c97017120.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：从卡组将1只满足条件的怪兽以表侧攻击表示特殊召唤
function c97017120.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送提示信息，要求玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c97017120.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
