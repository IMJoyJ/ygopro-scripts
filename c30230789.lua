--カラクリ商人 壱七七
-- 效果：
-- 这张卡可以攻击的场合必须作出攻击。场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。这张卡召唤成功时，从自己卡组把1张名字带有「机巧」的卡加入手卡。
function c30230789.initial_effect(c)
	-- 这张卡可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30230789,0))  --"变成守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c30230789.poscon)
	e3:SetOperation(c30230789.posop)
	c:RegisterEffect(e3)
	-- 这张卡召唤成功时，从自己卡组把1张名字带有「机巧」的卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30230789,1))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c30230789.tg)
	e4:SetOperation(c30230789.op)
	c:RegisterEffect(e4)
end
-- 判断效果的发动者（这张卡）是否处于表侧攻击表示，作为被选择为攻击对象时发动条件之一。
function c30230789.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 效果处理时，若这张卡仍表侧表示且与效果存在关联，则将其表示形式改变为表侧守备表示。
function c30230789.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 检索的筛选条件：卡名含有「机巧」字段（SetCard 0x11）且可以被加入手卡。
function c30230789.filter(c)
	return c:IsSetCard(0x11) and c:IsAbleToHand()
end
-- 发动时无额外条件；并设置操作信息：从己方卡组将1张卡加入手卡。
function c30230789.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果的操作信息：预定从玩家tp的卡组将1张卡加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从己方卡组选择1张满足条件的「机巧」卡，加入手卡并向对方展示。
function c30230789.op(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出卡片选择提示，提示当前玩家tp选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足 c30230789.filter 条件的「机巧」卡。
	local g=Duel.SelectMatchingCard(tp,c30230789.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
