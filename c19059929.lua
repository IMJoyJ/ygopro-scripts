--炎舞－「玉衝」
-- 效果：
-- 这张卡的发动时，选择对方场上盖放的1张魔法·陷阱卡。对方不能对应这张卡的发动把选择的卡发动。只要这张卡在场上存在，选择的卡不能发动。此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升100。
function c19059929.initial_effect(c)
	-- 这张卡的发动时，选择对方场上盖放的1张魔法·陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c19059929.target)
	e1:SetOperation(c19059929.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 选择对象为兽战士族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e2:SetValue(100)
	c:RegisterEffect(e2)
	-- 对方不能对应这张卡的发动把选择的卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
end
-- 这张卡的发动时，选择对方场上盖放的1张魔法·陷阱卡。
function c19059929.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 检索对方场上盖放的1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,e:GetHandler()) end
	-- 提示选择对方场上盖放的1张魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(19059929,0))  --"请选择对方场上盖放的1张魔法·陷阱卡"
	-- 选择对方场上盖放的1张魔法·陷阱卡
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,e:GetHandler())
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，防止对方在该卡发动时发动选择的卡
		Duel.SetChainLimit(c19059929.limit(g:GetFirst()))
	end
end
-- 返回一个限制连锁的函数，限制发动的卡不能是被选择的卡
function c19059929.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
-- 将选择的卡设置为该卡的对象
function c19059929.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
