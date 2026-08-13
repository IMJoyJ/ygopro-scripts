--魔妖仙獣 独眼群主
-- 效果：
-- ←3 【灵摆】 3→
-- 这个卡名的①②的灵摆效果1回合各能使用1次。
-- ①：以自己的灵摆区域1张「妖仙兽」卡为对象才能发动。那个灵摆刻度直到回合结束时变成11。这个回合，自己不是「妖仙兽」怪兽不能特殊召唤。
-- ②：自己结束阶段发动。这张卡回到持有者手卡。
-- 【怪兽效果】
-- 这张卡不用灵摆召唤不能特殊召唤。
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
-- ②：这张卡在怪兽区域存在，每次自己的卡的效果让这张卡以外的场上的卡回到手卡·卡组发动。自己场上的全部「妖仙兽」怪兽的攻击力上升500。
-- ③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c21364070.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性，使其拥有灵摆召唤、可以在灵摆区域发动等基础能力。
	aux.EnablePendulumAttribute(c)
	-- ①：以自己的灵摆区域1张「妖仙兽」卡为对象才能发动。那个灵摆刻度直到回合结束时变成11。这个回合，自己不是「妖仙兽」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21364070,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,21364070)
	e1:SetTarget(c21364070.target)
	e1:SetOperation(c21364070.operation)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段发动。这张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21364070,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,21364071)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c21364070.pretcon)
	e2:SetTarget(c21364070.prettg)
	e2:SetOperation(c21364070.pretop)
	c:RegisterEffect(e2)
	-- 这张卡不用灵摆召唤不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该特殊召唤限制效果的值：仅当使用灵摆召唤方式时才能特殊召唤，其他召唤方式均不允许。
	e3:SetValue(aux.penlimit)
	c:RegisterEffect(e3)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(21364070,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c21364070.thtg)
	e4:SetOperation(c21364070.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	-- ②：这张卡在怪兽区域存在，每次自己的卡的效果让这张卡以外的场上的卡回到手卡·卡组发动。自己场上的全部「妖仙兽」怪兽的攻击力上升500。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(21364070,3))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_TO_HAND)
	e6:SetCondition(c21364070.atkcon)
	e6:SetOperation(c21364070.atkop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e7)
	-- ③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(21364070,4))
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetCondition(c21364070.retcon)
	e8:SetTarget(c21364070.rettg)
	e8:SetOperation(c21364070.retop)
	c:RegisterEffect(e8)
	if not c21364070.global_check then
		c21364070.global_check=true
		-- ①：以自己的灵摆区域1张「妖仙兽」卡为对象才能发动。那个灵摆刻度直到回合结束时变成11。这个回合，自己不是「妖仙兽」怪兽不能特殊召唤。③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetLabel(21364070)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局连续效果的处理函数为aux.sumreg，用于在特殊召唤成功时给对应怪兽标记“本回合曾被特殊召唤”，供怪兽效果③的结束阶段回手判定使用。
		ge1:SetOperation(aux.sumreg)
		-- 将该特殊召唤成功时的事件记录效果注册为全局效果，使所有特殊召唤都会被检测到并执行标记。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义灵摆效果①的过滤器：判断卡是否满足作为对象的条件，即表侧表示、属于「妖仙兽」系列且当前灵摆刻度不是11。
function c21364070.scalefilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3) and c:GetCurrentScale()~=11
end
-- 灵摆效果①的发动时处理函数：确认对象选择是否合法，并让玩家选择自己灵摆区域1张符合条件的「妖仙兽」卡作为对象。
function c21364070.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c21364070.scalefilter(chkc) end
	-- 在发动时检查自己灵摆区域是否存在至少1张符合条件的「妖仙兽」卡，不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c21364070.scalefilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 向玩家显示选择消息，提示正在进行灵摆效果①的对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己灵摆区域选择1张符合条件的「妖仙兽」卡，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c21364070.scalefilter,tp,LOCATION_PZONE,0,1,1,nil)
end
-- 灵摆效果①的结算处理函数：将对象卡的灵摆刻度变成11直到回合结束，并给自己附加本回合不能特殊召唤「妖仙兽」以外怪兽的限制。
function c21364070.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得灵摆效果①选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那个灵摆刻度直到回合结束时变成11。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(11)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		tc:RegisterEffect(e2)
	end
	-- 这个回合，自己不是「妖仙兽」怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c21364070.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将本回合的“不能特殊召唤「妖仙兽」以外怪兽”限制效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
end
-- 特殊召唤限制的判断函数：若怪兽不是「妖仙兽」则不能特殊召唤。
function c21364070.splimit(e,c)
	return not c:IsSetCard(0xb3)
end
-- 灵摆效果②的发动条件函数：必须是自己的结束阶段。
function c21364070.pretcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，即只有自己回合的结束阶段才满足灵摆效果②的发动条件。
	return Duel.GetTurnPlayer()==tp
end
-- 灵摆效果②的发动时处理：声明可以发动，并登记将灵摆区的这张卡返回手卡。
function c21364070.prettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本效果处理时将把这张卡返回持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 灵摆效果②的结算处理：若这张卡仍与效果关联，则将其返回持有者手卡。
function c21364070.pretop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果为原因将这张卡送回其持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 怪兽效果①的发动时处理函数：选择对方场上1张能被返回手卡的卡作为对象，并登记回手卡信息。
function c21364070.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 发动时检查对方场上是否存在至少1张能被效果返回手卡的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择消息，提示选择要返回手卡的对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张能被返回手卡的卡，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：本效果处理时将把选择的对象卡返回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 怪兽效果①的结算处理：若对象卡仍与效果关联，则将其返回持有者手卡。
function c21364070.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得怪兽效果①选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果为原因将对象卡返回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判定一张卡是否因自己发动的效果而从场上回到手卡或卡组，用于触发怪兽效果②；需检查其之前位置、当前位置、效果原因及归属。
function c21364070.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_HAND+LOCATION_DECK)
		and c:IsReason(REASON_EFFECT) and (c:IsControler(tp) and c:IsReason(REASON_REDIRECT)
			or c:GetReasonPlayer()==tp and not c:IsReason(REASON_REDIRECT))
end
-- 怪兽效果②的触发条件：本次回手/回卡组的事件集合中存在符合条件的卡，且不包括这张卡自身。
function c21364070.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21364070.cfilter,1,e:GetHandler(),tp)
end
-- 攻击力上升的对象过滤器：自己场上表侧表示的「妖仙兽」怪兽。
function c21364070.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 怪兽效果②的结算处理：给自己场上全部表侧表示的「妖仙兽」怪兽分别赋予攻击力上升500的效果。
function c21364070.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上所有表侧表示的「妖仙兽」怪兽。
	local g=Duel.GetMatchingGroup(c21364070.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「妖仙兽」怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 怪兽效果③的发动条件：这张卡持有标记21364070，即这张卡是在本回合被特殊召唤过的。
function c21364070.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(21364070)~=0
end
-- 怪兽效果③的发动时处理：声明可以发动，并登记将这张卡返回手卡。
function c21364070.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本效果处理时将把这张卡返回持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 怪兽效果③的结算处理：若这张卡仍与效果关联，则将其返回持有者手卡。
function c21364070.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果为原因将这张卡送回持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
