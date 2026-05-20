--朱雀の召喚士
-- 效果：
-- ①：这张卡被对方怪兽的攻击破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的战士族怪兽攻击表示特殊召唤。
function c81354330.initial_effect(c)
	-- ①：这张卡被对方怪兽的攻击破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的战士族怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81354330,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c81354330.condition)
	e1:SetTarget(c81354330.target)
	e1:SetOperation(c81354330.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身被战斗破坏送去墓地，且攻击怪兽由对方控制
function c81354330.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		-- 检查进行攻击的怪兽是否由对方玩家控制
		and Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤卡组中攻击力1500以下、可以攻击表示特殊召唤的战士族怪兽
function c81354330.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 检查发动时的合法性（怪兽区域有空位且卡组有符合条件的卡），并设置特殊召唤的操作信息
function c81354330.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c81354330.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的战士族怪兽，以攻击表示特殊召唤到自己场上
function c81354330.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c81354330.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
