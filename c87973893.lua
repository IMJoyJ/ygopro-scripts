--甲虫装機の魔斧 ゼクトホーク
-- 效果：
-- 名字带有「甲虫装机」的怪兽才能装备。装备怪兽的攻击力上升1000。装备怪兽的攻击宣言时，对方不能把魔法·陷阱卡发动。
function c87973893.initial_effect(c)
	-- 名字带有「甲虫装机」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c87973893.target)
	e1:SetOperation(c87973893.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 名字带有「甲虫装机」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c87973893.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽的攻击宣言时，对方不能把魔法·陷阱卡发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(c87973893.accon)
	e4:SetOperation(c87973893.acop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给名字带有「甲虫装机」的怪兽
function c87973893.eqlimit(e,c)
	return c:IsSetCard(0x56)
end
-- 过滤条件：场上表侧表示的名字带有「甲虫装机」的怪兽
function c87973893.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 装备魔法卡发动时的对象选择与效果处理准备
function c87973893.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c87973893.filter(chkc) end
	-- 检查场上是否存在可以装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c87973893.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的名字带有「甲虫装机」的怪兽作为装备对象
	Duel.SelectTarget(tp,c87973893.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理：将此卡装备给目标怪兽
function c87973893.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 触发条件：装备怪兽进行攻击宣言时
function c87973893.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 攻击宣言时的效果处理：注册一个在伤害步骤结束前限制对方发动魔法·陷阱卡的效果
function c87973893.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 对方不能把魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c87973893.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册该限制玩家发动的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动的卡片类型：魔法·陷阱卡（卡片的发动）
function c87973893.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
