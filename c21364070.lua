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
	-- 为卡片添加灵摆怪兽属性，允许灵摆召唤和灵摆卡的发动
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
	-- 设置该效果为灵摆召唤的特殊召唤条件
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
		-- 注册一个全局持续效果，用于记录特殊召唤的怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetLabel(21364070)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置该全局效果的处理函数为aux.sumreg
		ge1:SetOperation(aux.sumreg)
		-- 将全局效果注册到玩家0（即所有玩家）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义一个过滤函数，用于判断灵摆区域的卡是否满足条件（正面表示、妖仙兽卡组、当前刻度不是11）
function c21364070.scalefilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3) and c:GetCurrentScale()~=11
end
-- 设置效果的目标选择函数，用于选择满足条件的灵摆区域的卡
function c21364070.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c21364070.scalefilter(chkc) end
	-- 检查是否有满足条件的灵摆区域的卡
	if chk==0 then return Duel.IsExistingTarget(c21364070.scalefilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的灵摆区域的卡作为效果对象
	Duel.SelectTarget(tp,c21364070.scalefilter,tp,LOCATION_PZONE,0,1,1,nil)
end
-- 设置效果的处理函数，用于执行效果
function c21364070.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡的左刻度设置为11
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
	-- 创建一个效果，禁止非妖仙兽怪兽在本回合特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c21364070.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e3,tp)
end
-- 定义一个过滤函数，用于判断是否为非妖仙兽怪兽
function c21364070.splimit(e,c)
	return not c:IsSetCard(0xb3)
end
-- 设置效果的触发条件，用于判断是否为当前回合玩家
function c21364070.pretcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 设置效果的处理信息，用于确定效果处理时的目标
function c21364070.prettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，指定将卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 设置效果的处理函数，用于执行效果
function c21364070.pretop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 设置效果的目标选择函数，用于选择对方场上的卡
function c21364070.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查是否有满足条件的对方场上的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的对方场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，指定将卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置效果的处理函数，用于执行效果
function c21364070.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义一个过滤函数，用于判断是否为因效果而回到手牌或卡组的卡
function c21364070.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_HAND+LOCATION_DECK)
		and c:IsReason(REASON_EFFECT) and (c:IsControler(tp) and c:IsReason(REASON_REDIRECT)
			or c:GetReasonPlayer()==tp and not c:IsReason(REASON_REDIRECT))
end
-- 设置效果的触发条件，用于判断是否有满足条件的卡因效果回到手牌或卡组
function c21364070.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21364070.cfilter,1,e:GetHandler(),tp)
end
-- 定义一个过滤函数，用于判断是否为正面表示的妖仙兽怪兽
function c21364070.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 设置效果的处理函数，用于执行效果
function c21364070.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的妖仙兽怪兽
	local g=Duel.GetMatchingGroup(c21364070.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每个妖仙兽怪兽增加500攻击力
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
-- 设置效果的触发条件，用于判断是否为特殊召唤回合
function c21364070.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(21364070)~=0
end
-- 设置效果的处理信息，用于确定效果处理时的目标
function c21364070.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，指定将卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 设置效果的处理函数，用于执行效果
function c21364070.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
