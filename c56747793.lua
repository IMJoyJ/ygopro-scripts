--団結の力
-- 效果：
-- ①：装备怪兽的攻击力·守备力上升自己场上的表侧表示怪兽数量×800。
function c56747793.initial_effect(c)
	-- ①：装备怪兽的攻击力·守备力上升自己场上的表侧表示怪兽数量×800。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c56747793.target)
	e1:SetOperation(c56747793.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力...上升自己场上的表侧表示怪兽数量×800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c56747793.value)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的...守备力上升自己场上的表侧表示怪兽数量×800。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(c56747793.value)
	c:RegisterEffect(e3)
	-- 装备怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 作为装备魔法卡发动时的对象选择与效果处理准备
function c56747793.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象并将其设为效果目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示该效果的处理包含装备卡片
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理，将自身装备给目标怪兽
function c56747793.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽攻击力·守备力上升数值的函数
function c56747793.value(e,c)
	-- 获取自己场上表侧表示怪兽的数量并乘以800作为上升数值
	return Duel.GetMatchingGroupCount(Card.IsFaceup,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)*800
end
