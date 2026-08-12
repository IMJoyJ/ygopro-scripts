--BK ヘッドギア
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只「燃烧拳击手」怪兽送去墓地。
-- ②：攻击表示的这张卡1回合只有1次不会被战斗破坏。
function c79867938.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只「燃烧拳击手」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79867938,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c79867938.target)
	e1:SetOperation(c79867938.operation)
	c:RegisterEffect(e1)
	-- ②：攻击表示的这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c79867938.valcon)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可以送去墓地的「燃烧拳击手」怪兽
function c79867938.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1084) and c:IsAbleToGrave()
end
-- 效果①的发动检测与操作信息设置
function c79867938.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组中是否存在至少1只可以送去墓地的「燃烧拳击手」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79867938.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果会将卡组中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1只「燃烧拳击手」怪兽送去墓地
function c79867938.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的「燃烧拳击手」怪兽
	local g=Duel.SelectMatchingCard(tp,c79867938.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断自身是否处于攻击表示，且破坏原因为战斗破坏
function c79867938.valcon(e,re,r,rp)
	return e:GetHandler():IsAttackPos() and bit.band(r,REASON_BATTLE)~=0
end
