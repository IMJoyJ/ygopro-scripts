--ペンギン・ナイトメア
-- 效果：
-- ①：这张卡反转的场合，以对方场上1张卡为对象发动。那张对方的卡回到持有者手卡。
-- ②：只要这张卡在怪兽区域存在，自己场上的水属性怪兽的攻击力上升200。
function c81306586.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1张卡为对象发动。那张对方的卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81306586,0))  --"返回手牌"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_FLIP)
	e1:SetTarget(c81306586.thtg)
	e1:SetOperation(c81306586.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的水属性怪兽的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为水属性怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e2:SetValue(200)
	c:RegisterEffect(e2)
end
-- 效果①的发动准备（检查合法对象、选择目标并设置操作信息）
function c81306586.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 给发动效果的玩家发送提示信息，提示其选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以回到手牌的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果①的效果处理（将选中的对象卡送回持有者手牌）
function c81306586.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 通过效果将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
