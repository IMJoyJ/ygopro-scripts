--魔弾の射手 カスパール
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
-- ②：和这张卡相同纵列有魔法·陷阱卡发动的场合才能发动。和那张发动的卡卡名不同的1张「魔弹」卡从卡组加入手卡。
function c32841045.initial_effect(c)
	-- 效果原文内容：①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32841045,1))  --"适用「魔弹射手 卡斯帕」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	-- 规则层面作用：设置效果目标为持有「魔弹」卡组的卡片。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetValue(32841045)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：和这张卡相同纵列有魔法·陷阱卡发动的场合才能发动。和那张发动的卡卡名不同的1张「魔弹」卡从卡组加入手卡。
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
-- 规则层面作用：判断连锁发动的魔法·陷阱卡是否在与该卡同纵列的位置上。
function c32841045.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
end
-- 规则层面作用：过滤满足条件的「魔弹」卡，且卡名不能与发动的卡相同。
function c32841045.thfilter(c,rc)
	return c:IsSetCard(0x108) and not c:IsCode(rc:GetCode()) and c:IsAbleToHand()
end
-- 规则层面作用：检查是否满足检索条件并设置操作信息。
function c32841045.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	-- 规则层面作用：判断是否满足检索条件，即卡组中是否存在符合条件的卡。
	if chk==0 then return rc and Duel.IsExistingMatchingCard(c32841045.thfilter,tp,LOCATION_DECK,0,1,nil,rc) end
	e:SetLabelObject(rc)
	-- 规则层面作用：设置连锁操作信息，表示将从卡组检索1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：执行检索并确认玩家手牌。
function c32841045.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：选择满足条件的1张卡从卡组加入手牌。
	local g=Duel.SelectMatchingCard(tp,c32841045.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabelObject())
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的卡送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面作用：向对方确认所选卡的卡面信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
