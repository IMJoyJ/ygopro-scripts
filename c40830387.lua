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
	-- 名字带有「古代的机械」的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c40830387.eqlimit)
	c:RegisterEffect(e2)
	-- 和装备怪兽进行战斗的怪兽在那个伤害步骤结束时破坏。
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
-- 检查装备对象是否为古代的机械怪兽（系列编号0x7）
function c40830387.eqlimit(e,c)
	return c:IsSetCard(0x7)
end
-- 筛选场上表侧表示的古代的机械怪兽
function c40830387.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7)
end
-- 选择要装备的古代的机械怪兽作为对象
function c40830387.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c40830387.filter(chkc) end
	-- 检查是否存在符合条件的古代的机械怪兽
	if chk==0 then return Duel.IsExistingTarget(c40830387.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择装备目标的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家在双方的怪兽区域选择一张古代的机械怪兽作为装备对象
	Duel.SelectTarget(tp,c40830387.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表明本次处理是装备卡的类别，装备卡为该永续魔法
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 在满足条件时执行装备，将该永续魔法装备到目标怪兽上
function c40830387.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在目标选择阶段选中的怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备，将永续魔法作为装备卡装备到目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 获取装备怪兽在当前伤害步骤中进行的战斗的对手怪兽
function c40830387.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local dt=nil
	-- 如果装备怪兽是攻击方，则对手怪兽为防守方
	if ec==Duel.GetAttacker() then dt=Duel.GetAttackTarget()
	-- 如果装备怪兽是防守方，则对手怪兽为攻击方
	elseif ec==Duel.GetAttackTarget() then dt=Duel.GetAttacker() end
	e:SetLabelObject(dt)
	return dt and dt:IsRelateToBattle()
end
-- 准备破坏对象，设置CATEGORY_DESTROY信息
function c40830387.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 声明将在伤害步骤结束时破坏对手怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 在伤害步骤结束时执行破坏，破坏对手怪兽
function c40830387.desop(e,tp,eg,ep,ev,re,r,rp)
	local dt=e:GetLabelObject()
	if dt:IsRelateToBattle() then
		-- 以效果原因破坏对手怪兽
		Duel.Destroy(dt,REASON_EFFECT)
	end
end
