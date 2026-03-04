--ガーディアンの力
-- 效果：
-- ①：装备怪兽进行战斗的攻击宣言时发动。给这张卡放置1个魔力指示物。
-- ②：装备怪兽的攻击力·守备力上升这张卡的魔力指示物数量×500。
-- ③：装备怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个魔力指示物取除。
function c1118137.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- ①：装备怪兽进行战斗的攻击宣言时发动。给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c1118137.target)
	e1:SetOperation(c1118137.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽的攻击力·守备力上升这张卡的魔力指示物数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1118137,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c1118137.ctcon)
	e2:SetTarget(c1118137.cttg)
	e2:SetOperation(c1118137.ctop)
	c:RegisterEffect(e2)
	-- ③：装备怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个魔力指示物取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c1118137.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 效果作用
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetTarget(c1118137.desreptg)
	e5:SetOperation(c1118137.desrepop)
	c:RegisterEffect(e5)
	-- 效果作用
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EFFECT_EQUIP_LIMIT)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
-- 选择装备怪兽
function c1118137.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否有可选择的装备怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择一个场上正面表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，准备装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的处理函数
function c1118137.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 攻击宣言时的触发条件判断
function c1118137.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断攻击怪兽是否为装备怪兽
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 魔力指示物增加的处理函数
function c1118137.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，准备增加魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 魔力指示物增加的处理函数
function c1118137.ctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 计算攻击力提升值
function c1118137.atkval(e,c)
	return e:GetHandler():GetCounter(0x1)*500
end
-- 破坏代替效果的触发条件判断
function c1118137.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) and not tg:IsReason(REASON_REPLACE)
		-- 检查是否可以移除场上魔力指示物
		and Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_EFFECT) end
	-- 询问玩家是否发动效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 破坏代替效果的处理函数
function c1118137.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 移除场上一个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_EFFECT+REASON_REPLACE)
end
