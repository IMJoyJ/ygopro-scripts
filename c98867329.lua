--災いの装備品
-- 效果：
-- 装备怪兽的攻击力下降自己场上存在的怪兽数量×600的数值。这张卡从场上送去墓地时，可以选择对方场上表侧表示存在的1只怪兽把这张卡装备。
function c98867329.initial_effect(c)
	-- （作为装备魔法卡发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c98867329.target)
	e1:SetOperation(c98867329.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力下降自己场上存在的怪兽数量×600的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c98867329.atkval)
	c:RegisterEffect(e2)
	-- （装备限制）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这张卡从场上送去墓地时，可以选择对方场上表侧表示存在的1只怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(98867329,0))  --"装备"
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c98867329.eqcon)
	e4:SetTarget(c98867329.eqtg)
	e4:SetOperation(c98867329.operation)
	c:RegisterEffect(e4)
end
-- 计算装备怪兽攻击力下降数值的辅助函数
function c98867329.atkval(e,c)
	-- 返回自己场上的怪兽数量×-600的数值
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)*-600
end
-- 装备魔法卡发动时的效果目标选择与处理
function c98867329.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动时，检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作，对象是这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动或效果触发时的装备效果处理
function c98867329.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的第一个目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检查这张卡是否是从场上送去墓地
function c98867329.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 送去墓地时触发效果的目标选择与处理
function c98867329.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 在发动时，检查自己魔陷区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且对方场上是否存在可以作为装备对象的表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作，对象是这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
