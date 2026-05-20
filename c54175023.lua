--ディメンション・ガーディアン
-- 效果：
-- 以自己场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，那只怪兽不会被战斗·效果破坏。那只怪兽从场上离开的场合这张卡破坏。
function c54175023.initial_effect(c)
	-- 以自己场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c54175023.target)
	e1:SetOperation(c54175023.tgop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，那只怪兽不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	-- 那只怪兽从场上离开的场合这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(c54175023.descon)
	e5:SetOperation(c54175023.desop)
	c:RegisterEffect(e5)
end
-- 卡片发动时的对象选择与合法性检查回调函数
function c54175023.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsPosition(POS_FACEUP_ATTACK) end
	-- 检查自己场上是否存在可以作为对象的表侧攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_ATTACK) end
	-- 设置选择卡片时的提示信息为“请选择表侧攻击表示的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择自己场上1只表侧攻击表示的怪兽作为对象
	Duel.SelectTarget(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEUP_ATTACK)
end
-- 卡片发动时的效果处理，使这张卡与对象怪兽建立持续对象关联
function c54175023.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 检查作为此卡对象的怪兽是否从场上离开
function c54175023.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 对象怪兽离场时，执行破坏此卡的效果处理
function c54175023.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
