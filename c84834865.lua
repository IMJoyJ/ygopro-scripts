--ドラゴンフライ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只攻击力1500以下的风属性怪兽在自己场上表侧攻击表示特殊召唤。
function c84834865.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只攻击力1500以下的风属性怪兽在自己场上表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84834865,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c84834865.condition)
	e1:SetTarget(c84834865.target)
	e1:SetOperation(c84834865.operation)
	c:RegisterEffect(e1)
end
-- 检查自身当前是否在墓地（确认被战斗破坏并送去墓地）
function c84834865.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 过滤卡组中攻击力1500以下、风属性且可以表侧攻击表示特殊召唤的怪兽
function c84834865.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动的合法性检测与目标确认
function c84834865.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c84834865.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组特殊召唤符合条件的怪兽
function c84834865.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c84834865.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧攻击表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
