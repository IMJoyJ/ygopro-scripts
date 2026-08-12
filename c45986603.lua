--強奪
-- 效果：
-- 可以给对方场上的怪兽装备。
-- ①：得到装备怪兽的控制权。
-- ②：对方准备阶段发动。对方回复1000基本分。
function c45986603.initial_effect(c)
	-- ①：得到装备怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c45986603.target)
	e1:SetOperation(c45986603.operation)
	c:RegisterEffect(e1)
	-- ②：对方准备阶段发动。对方回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45986603,0))  --"对方回复1000基本分"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c45986603.reccon)
	e2:SetTarget(c45986603.rectg)
	e2:SetOperation(c45986603.recop)
	c:RegisterEffect(e2)
	-- 装备对象限制
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c45986603.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽的控制权变更为装备者控制
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_CONTROL)
	e4:SetValue(c45986603.ctval)
	c:RegisterEffect(e4)
end
-- 用于筛选可以改变控制权的怪兽
function c45986603.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 限制装备对象
function c45986603.eqlimit(e,c)
	return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
-- 选择目标怪兽并设置操作信息
function c45986603.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c45986603.filter(chkc) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c45986603.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择一个对方场上的怪兽作为目标
	local g=Duel.SelectTarget(tp,c45986603.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置操作信息：将此卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的发动处理
function c45986603.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 触发条件判断
function c45986603.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保在对方准备阶段触发
	return tp~=Duel.GetTurnPlayer()
end
-- 设置回复LP的效果目标
function c45986603.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复LP的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置回复LP的数值为1000
	Duel.SetTargetParam(1000)
	-- 设置操作信息：对方回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end
-- 执行回复LP的效果处理
function c45986603.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 返回装备者的控制者
function c45986603.ctval(e,c)
	return e:GetHandlerPlayer()
end
