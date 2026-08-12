--DDプラウド・シュバリエ
-- 效果：
-- ←6 【灵摆】 6→
-- ①：1回合1次，支付500基本分，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降500。
-- ②：另一边的自己的灵摆区域没有「DD」卡存在的场合，这张卡的灵摆刻度变成5。
-- 【怪兽效果】
-- ①：这张卡召唤成功时才能发动。从自己的额外卡组把1只表侧表示的暗属性灵摆怪兽加入手卡。
function c17979378.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，支付500基本分，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17979378,0))  --"攻守变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c17979378.atkcost)
	e2:SetTarget(c17979378.atktg)
	e2:SetOperation(c17979378.atkop)
	c:RegisterEffect(e2)
	-- ②：另一边的自己的灵摆区域没有「DD」卡存在的场合，这张卡的灵摆刻度变成5。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_LSCALE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c17979378.sccon)
	e3:SetValue(5)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e4)
	-- ①：这张卡召唤成功时才能发动。从自己的额外卡组把1只表侧表示的暗属性灵摆怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetTarget(c17979378.thtg)
	e5:SetOperation(c17979378.thop)
	c:RegisterEffect(e5)
end
-- 支付500基本分的费用检查和支付操作
function c17979378.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 选择对方场上一只表侧表示的怪兽作为效果对象
function c17979378.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上一只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将选定的怪兽攻击力下降500
function c17979378.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给目标怪兽添加攻击力下降500的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断另一边的自己的灵摆区域是否存在「DD」卡
function c17979378.sccon(e)
	-- 检查另一边的自己的灵摆区域是否存在「DD」卡
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler(),0xaf)
end
-- 过滤函数，用于筛选满足条件的暗属性灵摆怪兽
function c17979378.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 设置效果发动时的处理信息，确定要将怪兽加入手牌
function c17979378.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的额外卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17979378.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，表示要将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 从额外卡组选择一只满足条件的怪兽加入手牌并确认
function c17979378.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组选择一只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c17979378.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认所选的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
