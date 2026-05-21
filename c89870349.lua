--M・HERO ブラスト
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。
-- ①：这张卡特殊召唤的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半。
-- ②：自己·对方回合1次，支付500基本分，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到手卡。
function c89870349.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置特殊召唤条件的限制为必须通过「假面变化」的效果进行特殊召唤。
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89870349,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetTarget(c89870349.atktg)
	e2:SetOperation(c89870349.atkop)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合1次，支付500基本分，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89870349,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c89870349.thcost)
	e3:SetTarget(c89870349.thtg)
	e3:SetOperation(c89870349.thop)
	c:RegisterEffect(e3)
end
-- ①号效果（减半攻击力）的发动准备与目标选择函数。
function c89870349.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以作为对象的可选表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①号效果（减半攻击力）的效果处理函数。
function c89870349.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ②号效果（回手牌）的发动代价（Cost）处理函数。
function c89870349.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动玩家是否能够支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让发动玩家支付500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 过滤出属于魔法或陷阱卡且可以回到手牌的卡片。
function c89870349.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②号效果（回手牌）的发动准备与目标选择函数。
function c89870349.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c89870349.thfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c89870349.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送“请选择要返回手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c89870349.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，表明此效果的处理包含“将选中的1张卡送回手牌”。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②号效果（回手牌）的效果处理函数。
function c89870349.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的魔法·陷阱卡对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果送回持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
