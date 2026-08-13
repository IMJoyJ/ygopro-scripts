--巨大化
-- 效果：
-- ①：自己基本分比对方少的场合，装备怪兽的攻击力变成原本攻击力的2倍。自己基本分比对方多的场合，装备怪兽的攻击力变成原本攻击力的一半。
function c22046459.initial_effect(c)
	-- 对应的效果原文为：“①：自己基本分比对方少的场合，装备怪兽的攻击力变成原本攻击力的2倍。自己基本分比对方多的场合，装备怪兽的攻击力变成原本攻击力的一半。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c22046459.target)
	e1:SetOperation(c22046459.operation)
	c:RegisterEffect(e1)
	-- 对应的效果原文为：“装备怪兽的攻击力变成原本攻击力的2倍。自己基本分比对方多的场合，装备怪兽的攻击力变成原本攻击力的一半。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetCondition(c22046459.condition)
	e2:SetValue(c22046459.value)
	c:RegisterEffect(e2)
	-- 对应的效果原文为：“装备怪兽”这一描述所要求的装备对象限制。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 发动时的取对象处理：检查场上是否存在表侧表示怪兽，选择1只作为装备对象，并设置装备相关的操作信息。
function c22046459.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 若在效果发动时进行合法性检查（chk==0），确认场上存在至少1只表侧表示怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上的表侧表示怪兽中选择1只作为装备对象，并同时将其设置为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为“装备”分类，对象是这张巨大化自身，数量为1，供后续处理或卡片判定使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若巨大化和对象怪兽都仍与效果相关且对象怪兽仍为表侧表示，则将巨大化作为装备卡装备给那只怪兽。
function c22046459.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张巨大化作为装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 该攻击力变化效果的发动条件：双方基本分不相等，即存在一方基本分比另一方少或多的情况。
function c22046459.condition(e)
	-- 判断双方玩家的基本分不相等，从而触发后续的攻击力增减效果。
	return Duel.GetLP(0)~=Duel.GetLP(1)
end
-- 根据装备卡控制者的基本分与对方基本分的比较结果计算攻击力变化：控制者基本分少则装备怪兽攻击力变为原本攻击力的2倍；多则变为原本攻击力的一半（向上取整）。
function c22046459.value(e,c)
	local p=e:GetHandler():GetControler()
	-- 如果装备卡控制者的基本分比对方少，则将装备怪兽的攻击力变为原本攻击力的2倍。
	if Duel.GetLP(p)<Duel.GetLP(1-p) then
		return c:GetBaseAttack()*2
	-- 否则如果装备卡控制者的基本分比对方多，则将装备怪兽的攻击力变为原本攻击力的一半（向上取整）。
	elseif Duel.GetLP(p)>Duel.GetLP(1-p) then
		return math.ceil(c:GetBaseAttack()/2)
	end
end
