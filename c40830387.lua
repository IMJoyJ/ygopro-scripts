--古代の機械掌
-- 效果：
-- 名字带有「古代的机械」的怪兽才能装备。和装备怪兽进行战斗的怪兽在那个伤害步骤结束时破坏。
function c40830387.initial_effect(c)
	-- 名字带有「古代的机械」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c40830387.target)
	e1:SetOperation(c40830387.operation)
	c:RegisterEffect(e1)
	-- 和装备怪兽进行战斗的怪兽在那个伤害步骤结束时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c40830387.eqlimit)
	c:RegisterEffect(e2)
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40830387,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c40830387.descon)
	e3:SetTarget(c40830387.destg)
	e3:SetOperation(c40830387.desop)
	c:RegisterEffect(e3)
end
-- 装备对象必须为名字带有「古代的机械」的怪兽
function c40830387.eqlimit(e,c)
	return c:IsSetCard(0x7)
end
-- 用于筛选名字带有「古代的机械」的表侧表示怪兽
function c40830387.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7)
end
-- 选择装备对象，筛选场上名字带有「古代的机械」的表侧表示怪兽
function c40830387.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c40830387.filter(chkc) end
	-- 判断是否满足选择装备对象的条件
	if chk==0 then return Duel.IsExistingTarget(c40830387.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽作为装备对象
	Duel.SelectTarget(tp,c40830387.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的处理函数
function c40830387.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前选择的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断战斗中是否为装备怪兽攻击
function c40830387.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local dt=nil
	-- 若装备怪兽为攻击怪兽，则获取其攻击目标
	if ec==Duel.GetAttacker() then dt=Duel.GetAttackTarget()
	-- 若装备怪兽为攻击目标，则获取其攻击怪兽
	elseif ec==Duel.GetAttackTarget() then dt=Duel.GetAttacker() end
	e:SetLabelObject(dt)
	return dt and dt:IsRelateToBattle()
end
-- 设置破坏效果的处理信息
function c40830387.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏效果的目标为战斗中被装备怪兽攻击的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 破坏效果的处理函数
function c40830387.desop(e,tp,eg,ep,ev,re,r,rp)
	local dt=e:GetLabelObject()
	if dt:IsRelateToBattle() then
		-- 将目标怪兽因效果而破坏
		Duel.Destroy(dt,REASON_EFFECT)
	end
end
