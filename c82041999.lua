--Jo－P.U.N.K.Mme.スパイダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：支付600基本分才能发动。从卡组把1张「朋克」陷阱卡加入手卡。
-- ②：对方场上的卡为对象的「朋克」卡的效果由自己发动时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。
function c82041999.initial_effect(c)
	-- ①：支付600基本分才能发动。从卡组把1张「朋克」陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82041999,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,82041999)
	e1:SetCost(c82041999.thcost)
	e1:SetTarget(c82041999.thtg)
	e1:SetOperation(c82041999.thop)
	c:RegisterEffect(e1)
	-- ②：对方场上的卡为对象的「朋克」卡的效果由自己发动时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82041999,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,82042000)
	e2:SetCondition(c82041999.atkcon)
	e2:SetTarget(c82041999.atktg)
	e2:SetOperation(c82041999.atkop)
	c:RegisterEffect(e2)
end
-- 定义支付600基本分的Cost函数
function c82041999.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能支付600基本分
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 支付600基本分
	Duel.PayLPCost(tp,600)
end
-- 过滤卡组中可以加入手牌的「朋克」陷阱卡
function c82041999.thfilter(c)
	return c:IsSetCard(0x171) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 定义检索效果的Target函数，检查卡组中是否存在符合条件的卡并设置操作信息
function c82041999.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「朋克」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82041999.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索效果的Operation函数，执行将卡组中的「朋克」陷阱卡加入手牌的操作
function c82041999.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的「朋克」陷阱卡
	local g=Duel.SelectMatchingCard(tp,c82041999.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤对方场上的卡
function c82041999.cfilter(c,tp)
	return c:IsControler(1-tp) and c:IsOnField()
end
-- 定义效果发动的Condition函数，检查是否为自己发动的「朋克」卡的效果以对方场上的卡为对象
function c82041999.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler():IsSetCard(0x171) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		and eg:IsExists(c82041999.cfilter,1,nil,tp)
end
-- 定义攻击力减半效果的Target函数，选择对方场上1只表侧表示怪兽作为对象
function c82041999.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义攻击力减半效果的Operation函数，使作为对象的怪兽攻击力直到回合结束时变成一半
function c82041999.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
