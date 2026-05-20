--ラドリートラップ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有怪兽召唤·特殊召唤的场合才能发动（同一连锁上最多1次）。从自己卡组上面把1张卡送去墓地。
-- ②：这张卡被效果从卡组送去墓地的场合，以「洗衣龙女困境」以外的这个回合被送去自己墓地的1张卡为对象才能发动。那张卡加入手卡。这个效果的发动后，直到下次的自己回合的结束时，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
function c79371769.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有怪兽召唤·特殊召唤的场合才能发动（同一连锁上最多1次）。从自己卡组上面把1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79371769,0))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c79371769.discon)
	e2:SetTarget(c79371769.distg)
	e2:SetOperation(c79371769.disop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡被效果从卡组送去墓地的场合，以「洗衣龙女困境」以外的这个回合被送去自己墓地的1张卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79371769,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,79371769)
	e4:SetCondition(c79371769.thcon)
	e4:SetTarget(c79371769.thtg)
	e4:SetOperation(c79371769.thop)
	c:RegisterEffect(e4)
end
-- 判断自己场上是否有怪兽召唤·特殊召唤
function c79371769.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
-- ①号效果的发动准备与操作信息注册
function c79371769.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡组顶端的卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息为将自己卡组顶端的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- ①号效果的实际处理，将卡组顶端的卡送去墓地
function c79371769.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果将目标玩家卡组顶端的指定数量的卡送去墓地
	Duel.DiscardDeck(p,d,REASON_EFFECT)
end
-- 检查这张卡是否是被效果从卡组送去墓地
function c79371769.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤出本回合被送去自己墓地的、「洗衣龙女困境」以外的、可以加入手卡的卡
function c79371769.thfilter(c,tid)
	return c:GetTurnID()==tid and not c:IsReason(REASON_RETURN) and not c:IsCode(79371769) and c:IsAbleToHand()
end
-- ②号效果的发动准备，选择符合条件的目标卡并设置回收手牌的操作信息
function c79371769.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前的回合数
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c79371769.thfilter(chkc,tid) end
	-- 检查自己墓地是否存在符合条件的可成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(c79371769.thfilter,tp,LOCATION_GRAVE,0,1,nil,tid) end
	-- 给玩家发送选择要加入手牌的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中1张符合条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c79371769.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,tid)
	-- 设置操作信息为将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②号效果的实际处理，将对象卡加入手牌并注册同名卡效果发动限制
function c79371769.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的第一个对象卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 尝试将对象卡因效果加入手牌，并确认其已成功进入手牌
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 这个效果的发动后，直到下次的自己回合的结束时，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c79371769.actlimit)
		e1:SetLabel(tc:GetCode())
		-- 判断当前回合玩家是否为自己，以确定限制效果的持续时间
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		-- 将限制发动效果的全局效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制发动效果的过滤函数，阻止玩家发动与加入手牌的卡同名的卡的效果
function c79371769.actlimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
