--シャドール・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以对方场上1张卡为对象才能发动。那张卡回到手卡。
-- ②：这张卡被效果送去墓地的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c77723643.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1张卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77723643,0))  --"回到手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,77723643)
	e1:SetCost(c77723643.cost)
	e1:SetTarget(c77723643.target)
	e1:SetOperation(c77723643.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77723643,1))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,77723643)
	e2:SetCondition(c77723643.descon)
	e2:SetCost(c77723643.cost)
	e2:SetTarget(c77723643.destg)
	e2:SetOperation(c77723643.desop)
	c:RegisterEffect(e2)
	c77723643.shadoll_flip_effect=e1
end
-- 效果发动Cost（向对方玩家展示发动了哪个效果）
function c77723643.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示“对方选择了：[当前效果描述]”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①号效果的发动准备（检查并选择对方场上的1张卡作为对象）
function c77723643.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在可以回到手牌的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择对方场上1张可以回到手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁运营信息，表示该效果包含“将选中的1张卡送回手牌”的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①号效果的处理（将作为对象的卡送回手牌）
function c77723643.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②号效果的发动条件（这张卡因效果被送去墓地）
function c77723643.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤魔法·陷阱卡的条件函数
function c77723643.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②号效果的发动准备（检查并选择场上的1张魔法·陷阱卡作为对象）
function c77723643.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c77723643.filter(chkc) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c77723643.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c77723643.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁运营信息，表示该效果包含“破坏选中的1张卡”的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②号效果的处理（破坏作为对象的魔法·陷阱卡）
function c77723643.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
