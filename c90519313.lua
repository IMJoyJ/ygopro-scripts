--検疫
-- 效果：
-- ①：自己·对方的结束阶段以对方场上盖放的1张魔法·陷阱卡为对象才能把这个效果发动。把那张卡确认，回到原状。
function c90519313.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的结束阶段以对方场上盖放的1张魔法·陷阱卡为对象才能把这个效果发动。把那张卡确认，回到原状。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90519313,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c90519313.cftg)
	e2:SetOperation(c90519313.cfop)
	c:RegisterEffect(e2)
end
-- 效果①的发动准备，检查并选择对方场上盖放的1张魔法·陷阱卡作为对象
function c90519313.cftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 检查对方场上是否存在可以作为对象的里侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择对方场上1张里侧表示的魔法·陷阱卡作为效果的对象
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
end
-- 效果①的效果处理，确认作为对象的卡片并使其回到原状
function c90519313.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 向发动效果的玩家确认该卡片，之后回到原状
		Duel.ConfirmCards(tp,tc)
	end
end
