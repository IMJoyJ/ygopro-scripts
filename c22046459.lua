--巨大化
-- 效果：
-- ①：自己基本分比对方少的场合，装备怪兽的攻击力变成原本攻击力的2倍。自己基本分比对方多的场合，装备怪兽的攻击力变成原本攻击力的一半。
function c22046459.initial_effect(c)
	-- ①：自己基本分比对方少的场合，装备怪兽的攻击力变成原本攻击力的2倍。自己基本分比对方多的场合，装备怪兽的攻击力变成原本攻击力的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c22046459.target)
	e1:SetOperation(c22046459.operation)
	c:RegisterEffect(e1)
	-- ①：自己基本分比对方少的场合，装备怪兽的攻击力变成原本攻击力的2倍。自己基本分比对方多的场合，装备怪兽的攻击力变成原本攻击力的一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetCondition(c22046459.condition)
	e2:SetValue(c22046459.value)
	c:RegisterEffect(e2)
	-- ①：自己基本分比对方少的场合，装备怪兽的攻击力变成原本攻击力的2倍。自己基本分比对方多的场合，装备怪兽的攻击力变成原本攻击力的一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 选择装备怪兽，满足条件的怪兽必须在主要怪兽区且表侧表示
function c22046459.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足选择装备怪兽的条件，即场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要装备的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个目标怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示将要进行装备处理
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽
function c22046459.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否满足装备效果触发条件，即双方基本分不同
function c22046459.condition(e)
	-- 双方基本分不同则触发效果
	return Duel.GetLP(0)~=Duel.GetLP(1)
end
-- 根据双方基本分关系计算装备怪兽攻击力变化值
function c22046459.value(e,c)
	local p=e:GetHandler():GetControler()
	-- 若自己基本分小于对方，则攻击力变为原本的2倍
	if Duel.GetLP(p)<Duel.GetLP(1-p) then
		return c:GetBaseAttack()*2
	-- 若自己基本分大于对方，则攻击力变为原本的一半
	elseif Duel.GetLP(p)>Duel.GetLP(1-p) then
		return math.ceil(c:GetBaseAttack()/2)
	end
end
