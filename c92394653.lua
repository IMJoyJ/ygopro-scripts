--スピリットの誘い
-- 效果：
-- 这张卡的控制者在每次自己的准备阶段支付500基本分。或者不支付500基本分让这张卡破坏。场上表侧表示存在的灵魂怪兽回到自己手卡时，由对方选择对方场上存在的1只怪兽，回到持有者的手卡。
function c92394653.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的灵魂怪兽回到自己手卡时，由对方选择对方场上存在的1只怪兽，回到持有者的手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92394653,0))  --"返回手牌"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c92394653.condition)
	e2:SetTarget(c92394653.target)
	e2:SetOperation(c92394653.operation)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在每次自己的准备阶段支付500基本分。或者不支付500基本分让这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c92394653.mtcon)
	e3:SetOperation(c92394653.mtop)
	c:RegisterEffect(e3)
end
c92394653.has_text_type=TYPE_SPIRIT
-- 过滤在场上表侧表示存在并回到自己手卡的灵魂怪兽
function c92394653.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsControler(tp) and c:GetPreviousTypeOnField()&TYPE_SPIRIT>0
end
-- 检查是否有符合条件的灵魂怪兽回到自己手卡，且此卡已在场上表侧表示存在
function c92394653.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c92394653.filter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 效果发动时的目标确认，设置将对方场上的怪兽返回手牌的操作信息
function c92394653.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上可以返回手牌的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息为：将对方场上的1只怪兽返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理，由对方选择其场上的1只怪兽返回持有者手牌
function c92394653.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方玩家发送提示信息，要求选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让对方玩家选择自己场上存在的1只可以返回手牌的怪兽
	local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送回持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 维持效果的条件函数，检查当前是否为自己的回合
function c92394653.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 维持效果的处理函数，让控制者选择支付500基本分或者将这张卡破坏
function c92394653.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者是否能支付500基本分，并由其选择是否支付
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(92394653,1)) then  --"是否要支付500基本分维持「灵魂的引诱」？"
		-- 扣除控制者500基本分作为维持代价
		Duel.PayLPCost(tp,500)
	else
		-- 因不支付维持基本分而将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
