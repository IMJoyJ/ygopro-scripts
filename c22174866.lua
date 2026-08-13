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
-- ①效果的发动条件：判定这张卡的控制者基本分是否比对方多，满足时攻击力·守备力下降效果适用。
function c22174866.adcon(e)
	local tp=e:GetHandlerPlayer()
	-- 返回当前效果持有者的LP是否大于对方LP，用于①效果的条件判定。
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- ②效果的发动条件：基本分回复的玩家是这张卡的控制者（自己回复LP时才能发动）。
function c22174866.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- ②效果的对象筛选：只选择对方场上的魔法·陷阱卡，且该卡能够加入手卡。
function c22174866.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的目标处理：以对方场上1张满足条件的魔法·陷阱卡为对象，并设置将该卡返回手牌的操作信息。
function c22174866.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c22174866.thfilter(chkc) end
	if chk==0 then return true end
	-- 显示“请选择要返回手牌的卡”的提示文字，供后续选择卡片时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1张符合条件的魔法·陷阱卡，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c22174866.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本效果的处理信息：将选中的卡返回持有者手牌（CATEGORY_TOHAND），数量为选择的卡片数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②效果解决时：取回之前选择的对象，若对象仍与效果关联，则将其返回持有者手牌。
function c22174866.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中记录的第一个效果对象（即选择的魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡返回持有者手牌，返回原因记为“效果”。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
