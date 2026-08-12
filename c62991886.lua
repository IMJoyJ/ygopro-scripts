--進化する人類
-- 效果：
-- 自己基本分比对方低的场合，装备怪兽的原本攻击力变成2400。自己基本分比对方高的场合，装备怪兽的原本攻击力变成1000。
function c62991886.initial_effect(c)
	-- （装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c62991886.target)
	e1:SetOperation(c62991886.operation)
	c:RegisterEffect(e1)
	-- 自己基本分比对方低的场合，装备怪兽的原本攻击力变成2400。自己基本分比对方高的场合，装备怪兽的原本攻击力变成1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetCondition(c62991886.condition)
	e2:SetValue(c62991886.value)
	c:RegisterEffect(e2)
	-- （装备限制）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 装备魔法卡发动的Target函数，用于选择要装备的怪兽
function c62991886.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置提示信息为选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象并设为效果目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为将这张卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动的Operation函数，执行装备操作
function c62991886.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 原本攻击力变化效果的适用条件：双方生命值不相等
function c62991886.condition(e)
	-- 判断双方玩家的生命值是否不相等
	return Duel.GetLP(0)~=Duel.GetLP(1)
end
-- 根据双方生命值的多少，决定装备怪兽的原本攻击力数值
function c62991886.value(e,c)
	local p=e:GetHandler():GetControler()
	-- 如果自己的生命值比对方低
	if Duel.GetLP(p)<Duel.GetLP(1-p) then
		return 2400
	-- 如果自己的生命值比对方高
	elseif Duel.GetLP(p)>Duel.GetLP(1-p) then
		return 1000
	end
end
