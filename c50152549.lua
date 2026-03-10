--しびれ薬
-- 效果：
-- 机械族以外的怪兽装备可能。装备怪兽不能攻击宣言。
function c50152549.initial_effect(c)
	-- 装备魔法卡的发动效果，可以将机械族以外的怪兽作为对象进行装备
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c50152549.target)
	e1:SetOperation(c50152549.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽不能攻击宣言
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	-- 装备对象限制，只能装备给非机械族怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c50152549.eqlimit)
	c:RegisterEffect(e4)
end
-- 判断目标怪兽是否为非机械族
function c50152549.eqlimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 筛选条件：表侧表示且不是机械族的怪兽
function c50152549.filter(c)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE)
end
-- 设置选择目标怪兽的处理流程，包括提示信息和选择操作
function c50152549.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50152549.filter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c50152549.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择装备对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c50152549.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次效果的处理信息为装备类别
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给选定的怪兽
function c50152549.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备动作，将装备卡装备到目标怪兽上
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
