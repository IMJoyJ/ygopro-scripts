--薔薇の刻印
-- 效果：
-- 从自己墓地把1只植物族怪兽除外，以对方场上1只表侧表示怪兽为对象才能把这张卡发动。
-- ①：得到装备怪兽的控制权。
-- ②：自己结束阶段发动。这张卡的①的效果直到下次的自己准备阶段无效。
function c45247637.initial_effect(c)
	-- ①：得到装备怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCost(c45247637.cost)
	e1:SetTarget(c45247637.target)
	e1:SetOperation(c45247637.operation)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段发动。这张卡的①的效果直到下次的自己准备阶段无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45247637,0))  --"控制权转移"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c45247637.retcon)
	e2:SetOperation(c45247637.retop)
	c:RegisterEffect(e2)
	-- 装备卡效果：设置控制权
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_CONTROL)
	e4:SetCondition(c45247637.ctcon)
	e4:SetValue(c45247637.ctval)
	c:RegisterEffect(e4)
	-- 装备对象限制
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c45247637.eqlimit)
	c:RegisterEffect(e5)
end
-- 检索满足条件的卡片组：植物族且可除外
function c45247637.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemove()
end
-- 效果作用：从自己墓地把1只植物族怪兽除外作为cost
function c45247637.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外条件
	if chk==0 then return Duel.IsExistingMatchingCard(c45247637.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只植物族怪兽除外
	local g=Duel.SelectMatchingCard(tp,c45247637.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡从墓地除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检索满足条件的卡片组：表侧表示怪兽
function c45247637.filter(c)
	return c:IsFaceup()
end
-- 效果作用：选择对方场上1只表侧表示怪兽作为对象
function c45247637.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c45247637.filter(chkc) end
	-- 检查是否满足选择对象条件
	if chk==0 then return Duel.IsExistingTarget(c45247637.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c45247637.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置操作信息：装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备对象限制条件
function c45247637.eqlimit(e,c)
	return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
-- 效果作用：将装备卡装备给目标怪兽
function c45247637.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 效果作用：在自己结束阶段发动
function c45247637.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 效果作用：注册标记，使①效果无效
function c45247637.retop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(45247637,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
end
-- 装备效果是否生效的判断条件
function c45247637.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(45247637)==0
end
-- 设置控制权的值
function c45247637.ctval(e,c)
	return e:GetHandlerPlayer()
end
