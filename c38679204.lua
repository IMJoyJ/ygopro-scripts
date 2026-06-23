--ヴァイロン・ステラ
-- 效果：
-- 这张卡从怪兽卡区域上送去墓地的场合，可以支付500基本分，把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。和这张卡的装备怪兽进行战斗的对方怪兽在那次伤害步骤结束时破坏。
function c38679204.initial_effect(c)
	-- 这张卡从怪兽卡区域上送去墓地的场合，可以支付500基本分，把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38679204,0))  --"当成装备卡装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c38679204.eqcon)
	e1:SetCost(c38679204.eqcost)
	e1:SetTarget(c38679204.eqtg)
	e1:SetOperation(c38679204.eqop)
	c:RegisterEffect(e1)
	-- 和这张卡的装备怪兽进行战斗的对方怪兽在那次伤害步骤结束时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38679204,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c38679204.descon)
	e2:SetTarget(c38679204.destg)
	e2:SetOperation(c38679204.desop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否从怪兽区域被送去墓地
function c38679204.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 支付500基本分的费用
function c38679204.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 选择装备对象，必须是己方场上表侧表示的怪兽
function c38679204.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查己方魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查己方场上是否存在表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果处理，将此卡装备给选中的怪兽
function c38679204.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备对象限制，只能装备给自己的怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c38679204.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备对象限制函数，只能装备给自己的怪兽
function c38679204.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end
-- 判断是否为战斗阶段结束时的破坏效果触发条件
function c38679204.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	local dt=nil
	-- 若装备怪兽是攻击怪兽，则获取攻击目标
	if ec==Duel.GetAttacker() then dt=Duel.GetAttackTarget()
	-- 若装备怪兽是防守怪兽，则获取攻击怪兽
	elseif ec==Duel.GetAttackTarget() then dt=Duel.GetAttacker() end
	e:SetLabelObject(dt)
	return dt and dt:IsRelateToBattle()
end
-- 设置破坏效果的操作信息
function c38679204.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 执行破坏效果，将对方怪兽破坏
function c38679204.desop(e,tp,eg,ep,ev,re,r,rp)
	local dt=e:GetLabelObject()
	if dt:IsRelateToBattle() then
		-- 将对方怪兽因效果破坏
		Duel.Destroy(dt,REASON_EFFECT)
	end
end
