--電脳増幅器
-- 效果：
-- 「人造人-念力震慑者」才能装备。这张卡的发动和效果不会被无效化。
-- ①：装备怪兽持有的「双方不能把场上的陷阱卡的效果发动，场上的陷阱卡的效果无效化」效果作为「对方不能把场上的陷阱卡的效果发动，对方场上的陷阱卡的效果无效化」适用。
-- ②：这张卡从场上离开时装备怪兽破坏。
function c303660.initial_effect(c)
	-- 记录此卡记载了「人造人-念力震慑者」的卡片密码，用于装备条件判断
	aux.AddCodeList(c,77585513)
	-- ①：装备怪兽持有的「双方不能把场上的陷阱卡的效果发动，场上的陷阱卡的效果无效化」效果作为「对方不能把场上的陷阱卡的效果发动，对方场上的陷阱卡的效果无效化」适用
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTarget(c303660.target)
	e1:SetOperation(c303660.operation)
	c:RegisterEffect(e1)
	-- 「人造人-念力震慑者」才能装备
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c303660.eqlimit)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上离开时装备怪兽破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(303660)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e3)
	-- 这张卡的发动和效果不会被无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(c303660.desop)
	c:RegisterEffect(e4)
	-- 装备怪兽持有的「双方不能把场上的陷阱卡的效果发动，场上的陷阱卡的效果无效化」效果作为「对方不能把场上的陷阱卡的效果发动，对方场上的陷阱卡的效果无效化」适用
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_DISABLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e5)
end
-- 装备对象必须为「人造人-念力震慑者」
function c303660.eqlimit(e,c)
	return c:IsCode(77585513)
end
-- 筛选场上正面表示的「人造人-念力震慑者」怪兽
function c303660.filter(c)
	return c:IsFaceup() and c:IsCode(77585513)
end
-- 设置装备目标选择的处理逻辑
function c303660.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c303660.filter(chkc) end
	-- 判断场上是否存在符合条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(c303660.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个符合条件的装备目标
	Duel.SelectTarget(tp,c303660.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c303660.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 当装备卡离开场时触发破坏效果
function c303660.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将装备怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
