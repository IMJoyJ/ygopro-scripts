--ミュートリアル・ビースト
-- 效果：
-- 这张卡不用「秘异三变」卡的效果不能特殊召唤。这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡不会成为对方怪兽的效果的对象。
-- ②：对方把魔法卡的效果发动时，从自己的手卡·场上把1张卡除外才能发动。那个发动无效并除外。
-- ③：这张卡被对方破坏的场合，以除外的1张自己的「秘异三变」陷阱卡为对象才能发动。那张卡加入手卡。
function c34695290.initial_effect(c)
	-- ①：这张卡不会成为对方怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c34695290.splimit)
	c:RegisterEffect(e1)
	-- ②：对方把魔法卡的效果发动时，从自己的手卡·场上把1张卡除外才能发动。那个发动无效并除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c34695290.ctval)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方破坏的场合，以除外的1张自己的「秘异三变」陷阱卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCountLimit(1,34695290)
	e3:SetCondition(c34695290.negcon)
	e3:SetCost(c34695290.negcost)
	-- 设置效果目标为辅助函数aux.nbtg，用于处理连锁无效化和除外操作。
	e3:SetTarget(aux.nbtg)
	e3:SetOperation(c34695290.negop)
	c:RegisterEffect(e3)
	-- ②：对方把魔法卡的效果发动时，从自己的手卡·场上把1张卡除外才能发动。那个发动无效并除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,34695291)
	e4:SetCondition(c34695290.thcon)
	e4:SetTarget(c34695290.thtg)
	e4:SetOperation(c34695290.thop)
	c:RegisterEffect(e4)
end
-- 特殊召唤条件：必须通过「秘异三变」卡的效果进行特殊召唤。
function c34695290.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x157)
end
-- 效果不会成为对方怪兽的效果对象。
function c34695290.ctval(e,re,rp)
	-- 效果不会成为对方怪兽的效果对象。
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- 连锁发动条件：对方发动魔法卡且未被破坏。
function c34695290.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		-- 对方发动魔法卡且该连锁可被无效。
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- 支付除外1张手卡或场上的卡作为代价。
function c34695290.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外1张手卡或场上的卡的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张手卡或场上的卡进行除外。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡除外作为代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 执行连锁无效化和除外操作。
function c34695290.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果连锁发动被成功无效，则将目标卡除外。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将连锁目标卡除外。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 被破坏的场合触发效果：对方破坏此卡时。
function c34695290.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤函数：选择除外区中满足条件的「秘异三变」陷阱卡。
function c34695290.thtgfilter(c)
	return c:IsSetCard(0x157) and c:IsType(TYPE_TRAP) and c:IsAbleToHand() and c:IsFaceup()
end
-- 设置效果目标为选择除外区中的「秘异三变」陷阱卡。
function c34695290.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c34695290.thtgfilter(chkc) end
	-- 检查是否存在满足条件的除外区中的卡。
	if chk==0 then return Duel.IsExistingTarget(c34695290.thtgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张除外区中的「秘异三变」陷阱卡。
	local g=Duel.SelectTarget(tp,c34695290.thtgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息为将选中的卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行将选中的卡加入手牌的操作。
function c34695290.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
