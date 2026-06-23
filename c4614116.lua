--闇・エネルギー
-- 效果：
-- 恶魔族怪兽才能装备。
-- ①：装备怪兽的攻击力·守备力上升300。
function c4614116.initial_effect(c)
	-- ①：装备怪兽的攻击力·守备力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c4614116.target)
	e1:SetOperation(c4614116.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力·守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 恶魔族怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c4614116.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备对象必须为恶魔族怪兽
function c4614116.eqlimit(e,c)
	return c:IsRace(RACE_FIEND)
end
-- 筛选场上正面表示的恶魔族怪兽
function c4614116.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 选择装备目标，要求为场上正面表示的恶魔族怪兽
function c4614116.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4614116.filter(chkc) end
	-- 判断是否满足选择装备目标的条件
	if chk==0 then return Duel.IsExistingTarget(c4614116.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个符合条件的场上怪兽作为装备对象
	Duel.SelectTarget(tp,c4614116.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给选中的怪兽
function c4614116.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
