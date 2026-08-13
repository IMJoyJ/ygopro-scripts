--DDプラウド・シュバリエ
-- 效果：
-- ←6 【灵摆】 6→
-- ①：1回合1次，支付500基本分，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降500。
-- ②：另一边的自己的灵摆区域没有「DD」卡存在的场合，这张卡的灵摆刻度变成5。
-- 【怪兽效果】
-- ①：这张卡召唤成功时才能发动。从自己的额外卡组把1只表侧表示的暗属性灵摆怪兽加入手卡。
function c17979378.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆召唤以及作为灵摆卡在灵摆区域发动。
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
-- 灵摆效果①的发动代价函数：先检查能否支付500基本分，能则在实际发动时支付500LP。
function c17979378.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：若当前是检查（chk=0），判断玩家能否支付500基本分，作为发动条件之一。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 灵摆效果①的取对象目标选择函数：选择对方场上1只表侧表示怪兽为对象，并处理对象合法性确认。
function c17979378.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 目标检查阶段：确认对方场上是否存在至少1只表侧表示怪兽可作为对象，若无则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择表侧表示的卡”的选择提示，并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 灵摆效果①的效果处理函数：取得对象怪兽，若仍表侧且与效果关联，则使其攻击力下降500。
function c17979378.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一个效果对象（即选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 灵摆效果②的发动条件判断函数：检查自己的另一个灵摆区域是否不存在「DD」卡，若不存在则条件成立。
function c17979378.sccon(e)
	-- 判断自己灵摆区域是否存在「DD」卡：若不存在（not）则返回真，即效果②适用。
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler(),0xaf)
end
-- 怪兽效果①的检索过滤条件：卡必须为表侧表示、灵摆怪兽、暗属性，并且可以被加入手卡。
function c17979378.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 怪兽效果①的发动目标函数：确认额外卡组存在符合条件的表侧暗属性灵摆怪兽，并设置回手牌的操作信息。
function c17979378.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：额外卡组中是否存在至少1张符合条件的表侧暗属性灵摆怪兽，若无则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17979378.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 把本次效果处理信息设为“从额外卡组将1张卡加入手卡”，用于后续系统检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的效果处理函数：从额外卡组选择1张符合条件的怪兽加入手卡，并让对方确认。
function c17979378.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示“请选择要加入手牌的卡”的选择提示，并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中选择1张符合条件的表侧暗属性灵摆怪兽，返回选择组g。
	local g=Duel.SelectMatchingCard(tp,c17979378.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者的手卡（nil表示返回持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
