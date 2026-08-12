--旋風剣
-- 效果：
-- 名字带有「命运英雄」的怪兽才能装备。装备怪兽进行攻击的场合，那个伤害步骤结束时把场上1张魔法或者陷阱卡破坏。
function c22147147.initial_effect(c)
	-- 发动时选择1只表侧表示的名字带有「命运英雄」的怪兽进行装备；效果原文内容：名字带有「命运英雄」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c22147147.target)
	e1:SetOperation(c22147147.operation)
	c:RegisterEffect(e1)
	-- 限制装备对象只能是名字带有「命运英雄」的怪兽；效果原文内容：名字带有「命运英雄」的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c22147147.eqlimit)
	c:RegisterEffect(e2)
	-- 当装备怪兽进行攻击时，在伤害步骤结束时选择并破坏场上1张魔法或陷阱卡；效果原文内容：装备怪兽进行攻击的场合，那个伤害步骤结束时把场上1张魔法或者陷阱卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22147147,0))  --"魔陷破坏"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c22147147.descon)
	e3:SetTarget(c22147147.destg)
	e3:SetOperation(c22147147.desop)
	c:RegisterEffect(e3)
end
-- 限制装备对象的函数：返回目标怪兽c是否为名字带有「命运英雄」系列（0xc008）的卡片。
function c22147147.eqlimit(e,c)
	return c:IsSetCard(0xc008)
end
-- 装备选择过滤函数：返回目标怪兽c是否为表侧表示且名字带有「命运英雄」系列（0xc008）的卡片。
function c22147147.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 装备发动时的目标选择函数：检查是否已选择目标；若未选择则验证场上是否存在满足filter条件的怪兽；提示玩家选择装备对象；执行目标选择；设置操作信息为CATEGORY_EQUIP。
function c22147147.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c22147147.filter(chkc) end
	-- 验证阶段：检查场上是否存在满足c22147147.filter条件的怪兽（即表侧表示且名字带有「命运英雄」系列的怪兽），数量为1张。
	if chk==0 then return Duel.IsExistingTarget(c22147147.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡，显示提示信息“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 执行目标选择：在目标玩家的怪兽区选择1张满足c22147147.filter条件的怪兽作为装备对象。
	Duel.SelectTarget(tp,c22147147.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：指定当前连锁为CATEGORY_EQUIP类型，处理的卡为旋风剑自身，数量为1，目标玩家为0，位置为0。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备执行函数：获取选择的目标怪兽，若旋风剑和目标怪兽均仍处于效果处理状态且目标怪兽为表侧表示，则将旋风剑装备给该怪兽。
function c22147147.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡，即之前选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将旋风剑（e:GetHandler()）装备给目标怪兽tc。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 破坏触发条件函数：判断当前攻击者是否为旋风剑所装备的怪兽。
function c22147147.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前攻击者是否等于旋风剑所装备的目标怪兽，用于判断是否满足伤害步骤结束时触发破坏效果的条件。
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 破坏目标过滤函数：返回目标卡c是否为魔法卡或陷阱卡。
function c22147147.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标选择函数：检查是否已选择目标；若未选择则直接返回true（因效果处理时已确定目标）；提示玩家选择要破坏的卡；选择1张满足desfilter条件的魔法/陷阱卡作为目标；设置操作信息为CATEGORY_DESTROY。
function c22147147.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c22147147.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡，显示提示信息“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1张位于场上（魔法陷阱区或怪兽区）的魔法或陷阱卡作为破坏目标。
	local g=Duel.SelectTarget(tp,c22147147.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：指定当前连锁为CATEGORY_DESTROY类型，目标卡组为所选卡组g，数量为g中卡的数量，目标玩家为0，位置为0。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏执行函数：获取选择的目标卡，若该卡仍处于效果处理状态，则以REASON_EFFECT原因将其破坏。
function c22147147.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡，即之前选择的要破坏的魔法/陷阱卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）破坏目标卡tc。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
