--魔弾の射手 カスパール
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
-- ②：和这张卡相同纵列有魔法·陷阱卡发动的场合才能发动。和那张发动的卡卡名不同的1张「魔弹」卡从卡组加入手卡。
function c32841045.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32841045,1))  --"适用「魔弹射手 卡斯帕」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	-- 设置e1的效果适用对象为手卡中持有「魔弹」字段的卡（用于限制哪些「魔弹」魔法卡可以被允许在对方回合从手卡发动）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetValue(32841045)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：和这张卡相同纵列有魔法·陷阱卡发动的场合才能发动。和那张发动的卡卡名不同的1张「魔弹」卡从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32841045,0))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,32841045)
	e3:SetCondition(c32841045.thcon)
	e3:SetTarget(c32841045.thtg)
	e3:SetOperation(c32841045.thop)
	c:RegisterEffect(e3)
end
-- ②效果的发动条件判定：本次连锁必须是魔法·陷阱卡的发动，且发动的卡片必须与这张卡处于同一纵列（满足二者才可发动）。
function c32841045.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
end
-- 检索候选卡的条件：持有「魔弹」字段、卡名与发动的魔陷卡不同、且可以被加入手卡。
function c32841045.thfilter(c,rc)
	return c:IsSetCard(0x108) and not c:IsCode(rc:GetCode()) and c:IsAbleToHand()
end
-- ②效果的Target处理：chk==0时检查卡组中是否存在符合条件的「魔弹」卡；chk==1（确认发动）时保存发动的魔陷卡作为参照，并登记从卡组检索1张卡加入手卡的操作信息。
function c32841045.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	-- 效果发动时（chk==0）检查：发动的魔陷卡存在，并且卡组中存在至少1张符合条件的「魔弹」卡（卡名不同且能加入手卡），否则不能发动。
	if chk==0 then return rc and Duel.IsExistingMatchingCard(c32841045.thfilter,tp,LOCATION_DECK,0,1,nil,rc) end
	e:SetLabelObject(rc)
	-- 向Duel登记操作信息：本次效果将把1张卡从卡组加入手卡（不取对象，处理时选择），供相关卡牌响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：提示玩家选择1张与所发动的魔陷卡卡名不同的「魔弹」卡，将其加入手卡，并向对方展示该卡。
function c32841045.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示‘请选择要加入手牌的卡’的选择提示，并指定由当前玩家tp进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己卡组中选出1张满足thfilter条件的「魔弹」卡（排除作为参照的发动的魔陷卡同名卡）。
	local g=Duel.SelectMatchingCard(tp,c32841045.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabelObject())
	if g:GetCount()>0 then
		-- 将选中的卡以效果处理（REASON_EFFECT）送入其持有者的手卡（nil表示送到持有者手卡，即自己手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认（符合‘加入手卡’的检索公开要求）。
		Duel.ConfirmCards(1-tp,g)
	end
end
