--混沌球体
-- 效果：
-- 这张卡只要在场上表侧表示存在，也当作光属性使用。这张卡1回合只有1次不会被战斗破坏。这张卡上级召唤成功时，可以从卡组把1只3星怪兽加入手卡。
function c82693042.initial_effect(c)
	-- 这张卡只要在场上表侧表示存在，也当作光属性使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c82693042.valcon)
	c:RegisterEffect(e2)
	-- 这张卡上级召唤成功时，可以从卡组把1只3星怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82693042,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c82693042.thcon)
	e3:SetTarget(c82693042.thtg)
	e3:SetOperation(c82693042.thop)
	c:RegisterEffect(e3)
end
-- 判定破坏原因是否为战斗破坏
function c82693042.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 判定是否为上级召唤成功
function c82693042.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤卡组中等级为3且可以加入手牌的怪兽
function c82693042.filter(c)
	return c:IsLevel(3) and c:IsAbleToHand()
end
-- 检索效果的发动准备（检查可行性并设置操作信息）
function c82693042.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82693042.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理（从卡组选择1只3星怪兽加入手牌并给对方确认）
function c82693042.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c82693042.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
