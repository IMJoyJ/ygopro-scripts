--アロマージ－カナンガ
-- 效果：
-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降500。
-- ②：1回合1次，自己基本分回复的场合，以对方场上1张魔法·陷阱卡为对象发动。那张卡回到持有者手卡。
function c22174866.initial_effect(c)
	-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c22174866.adcon)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己基本分回复的场合，以对方场上1张魔法·陷阱卡为对象发动。那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_RECOVER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c22174866.thcon)
	e3:SetTarget(c22174866.thtg)
	e3:SetOperation(c22174866.thop)
	c:RegisterEffect(e3)
end
-- 判断是否满足效果①的发动条件，即当前玩家的LP是否高于对方玩家的LP
function c22174866.adcon(e)
	local tp=e:GetHandlerPlayer()
	-- 返回当前玩家的LP是否高于对方玩家的LP
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- 判断是否满足效果②的发动条件，即当前处理的回复LP事件是否由自己发动
function c22174866.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 过滤对方场上的魔法或陷阱卡，确保这些卡可以被送回手牌
function c22174866.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果②的发动目标，选择对方场上的1张魔法或陷阱卡作为目标
function c22174866.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c22174866.thfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1张魔法或陷阱卡作为效果②的目标
	local g=Duel.SelectTarget(tp,c22174866.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果②的处理信息，表示将目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行效果②的处理，将目标卡送回持有者手牌
function c22174866.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回其持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
