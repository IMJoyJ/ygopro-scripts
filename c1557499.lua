--銀の弓矢
-- 效果：
-- 天使族才能装备。1只装备怪兽的攻击力·守备力上升300。
function c1557499.initial_effect(c)
	-- 装备魔法卡的发动效果，可以自由连锁，需要选择一个天使族的怪兽作为装备对象
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c1557499.target)
	e1:SetOperation(c1557499.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 装备怪兽的守备力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 装备对象必须为天使族怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c1557499.eqlimit)
	c:RegisterEffect(e4)
end
-- 判断装备对象是否为天使族
function c1557499.eqlimit(e,c)
	return c:IsRace(RACE_FAIRY)
end
-- 筛选场上正面表示的天使族怪兽
function c1557499.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end
-- 选择装备目标，提示玩家选择一个天使族怪兽
function c1557499.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1557499.filter(chkc) end
	-- 检查是否有满足条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(c1557499.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择装备对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c1557499.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次效果的处理信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽
function c1557499.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备卡的装备动作
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
