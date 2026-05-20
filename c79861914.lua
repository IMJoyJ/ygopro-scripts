--妖仙大旋風
-- 效果：
-- 支付800基本分才能把这张卡发动。
-- ①：1回合1次，自己场上的表侧表示的「妖仙兽」怪兽回到手卡的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
-- ②：自己回合这张卡的①的效果没有适用的场合，那个回合的结束阶段这张卡破坏。
function c79861914.initial_effect(c)
	-- 支付800基本分才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c79861914.cost)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上的表侧表示的「妖仙兽」怪兽回到手卡的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79861914,0))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1)
	e2:SetCondition(c79861914.condition)
	e2:SetTarget(c79861914.target)
	e2:SetOperation(c79861914.operation)
	c:RegisterEffect(e2)
	-- ②：自己回合这张卡的①的效果没有适用的场合，那个回合的结束阶段这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79861914,1))  --"这张卡破坏"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c79861914.descon)
	e3:SetOperation(c79861914.desop)
	c:RegisterEffect(e3)
end
-- 卡片发动时的Cost（支付基本分）处理函数
function c79861914.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 扣除玩家800基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤条件：自己场上表侧表示的「妖仙兽」怪兽回到手卡
function c79861914.cfilter(c,tp)
	return c:IsSetCard(0xb3) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 发动条件：检查回到手卡的卡片中是否存在满足过滤条件的卡
function c79861914.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c79861914.cfilter,1,nil,tp)
end
-- 效果①的对象选择与发动准备函数
function c79861914.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在可以回到手卡的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以回到手卡的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理（将对象卡送回手卡，并注册已适用效果的标记）
function c79861914.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送回持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	e:GetHandler():RegisterFlagEffect(79861914,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的破坏条件检查函数
function c79861914.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己回合，且本回合未适用过效果①（未注册标记）
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(79861914)==0
end
-- 效果②的破坏效果处理函数
function c79861914.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
