--甲虫装機の魔弓 ゼクトアロー
-- 效果：
-- 名字带有「甲虫装机」的怪兽才能装备。装备怪兽的攻击力上升500。对方不能对应装备怪兽的效果的发动把魔法·陷阱·效果怪兽的效果发动。
function c87047074.initial_effect(c)
	-- 名字带有「甲虫装机」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c87047074.target)
	e1:SetOperation(c87047074.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 名字带有「甲虫装机」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c87047074.eqlimit)
	c:RegisterEffect(e3)
	-- 对方不能对应装备怪兽的效果的发动把魔法·陷阱·效果怪兽的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c87047074.chcon)
	e4:SetOperation(c87047074.chop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给名字带有「甲虫装机」的怪兽
function c87047074.eqlimit(e,c)
	return c:IsSetCard(0x56)
end
-- 过滤条件：场上表侧表示的名字带有「甲虫装机」的怪兽
function c87047074.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 装备魔法卡发动时的靶向选择与效果处理准备
function c87047074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c87047074.filter(chkc) end
	-- 判断场上是否存在可装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c87047074.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择并锁定一个表侧表示的「甲虫装机」怪兽作为装备对象
	Duel.SelectTarget(tp,c87047074.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理：将自身装备给目标怪兽
function c87047074.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 连锁限制的触发条件：发动效果的卡是此卡的装备怪兽
function c87047074.chcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()==e:GetHandler():GetEquipTarget()
end
-- 连锁限制的效果处理：设定连锁限制
function c87047074.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 设定连锁限制函数，限制后续的连锁发动
	Duel.SetChainLimit(c87047074.chlimit)
end
-- 连锁限制条件：只有发动效果的玩家自身可以继续连锁（即对方不能连锁）
function c87047074.chlimit(e,ep,tp)
	return ep==tp
end
