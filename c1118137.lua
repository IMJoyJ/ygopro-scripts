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
	-- ①：装备怪兽进行战斗的攻击宣言时发动。给这张卡放置1个魔力指示物。
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
	-- ②：装备怪兽的攻击力·守备力上升这张卡的魔力指示物数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c1118137.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ③：装备怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个魔力指示物取除。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetTarget(c1118137.desreptg)
	e5:SetOperation(c1118137.desrepop)
	c:RegisterEffect(e5)
	-- 设置装备限制，使这张卡只能装备1只怪兽
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EFFECT_EQUIP_LIMIT)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
c1118137.mentioned_counter={
	[0x1]=true,
}
-- 指定装备目标的选择函数，检查场上有无里侧表示以外的怪兽作为装备对象
function c1118137.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场地上是否存在攻击表示或守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从场上表侧表示的怪兽中选择1只作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明本次处理的是装备分类效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备处理的函数，将这张卡装备给目标怪兽
function c1118137.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 攻击宣言时的触发条件函数，判断装备怪兽是否正在进行攻击或被攻击
function c1118137.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断装备怪兽是否为当前战斗的攻击方或攻击对象
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 放置魔力指示物的目标设置函数
function c1118137.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明本次处理的是指示物分类效果
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 执行放置魔力指示物的操作，给这张卡放置1个魔力指示物
function c1118137.ctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 攻击力数值的计算函数，返回魔力指示物数量×500作为攻击力加成
function c1118137.atkval(e,c)
	return e:GetHandler():GetCounter(0x1)*500
end
-- 代替破坏的触发条件函数，判断装备怪兽是否因战斗或效果被破坏且有魔力指示物可移除
function c1118137.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) and not tg:IsReason(REASON_REPLACE)
		-- 检查玩家是否能够移除1个魔力指示物
		and Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_EFFECT) end
	-- 让玩家选择是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏的处理函数，执行移除魔力指示物代替破坏的操作
function c1118137.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 移除玩家场上1个魔力指示物，代替装备怪兽被破坏
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_EFFECT+REASON_REPLACE)
end
