--ガーディアンの力
-- 效果：
-- ①：装备怪兽进行战斗的攻击宣言时发动。给这张卡放置1个魔力指示物。
-- ②：装备怪兽的攻击力·守备力上升这张卡的魔力指示物数量×500。
-- ③：装备怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个魔力指示物取除。
function c1118137.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 注册卡片发动（装备魔法卡发动）效果：选择场上1只表侧表示怪兽为对象，将这张卡装备给那只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c1118137.target)
	e1:SetOperation(c1118137.operation)
	c:RegisterEffect(e1)
	-- 注册效果①：装备怪兽进行战斗的攻击宣言时强制发动的诱发效果，给这张卡放置1个魔力指示物。
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
	-- 注册效果②：装备怪兽的攻击力·守备力上升这张卡上的魔力指示物数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c1118137.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 注册效果③：装备怪兽被战斗·效果破坏的场合，可以去除自己场上1个魔力指示物作为代替。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetTarget(c1118137.desreptg)
	e5:SetOperation(c1118137.desrepop)
	c:RegisterEffect(e5)
	-- 注册装备限制效果：此卡只能装备给场上的表侧表示怪兽。
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
-- 效果发动的目标选择函数，选择场上1只表侧表示怪兽为装备对象，并设置装备分类操作信息。
function c1118137.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为装备对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择装备目标的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备操作，目标卡为这张装备魔法卡。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果发动的操作执行函数，确认卡片与装备对象有效后将这张卡装备给目标怪兽。
function c1118137.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将这张卡装备给选中的目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 效果①的发动条件函数，检查攻击怪兽或被攻击的目标怪兽是否为这张卡的装备怪兽。
function c1118137.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断攻击怪兽或攻击目标怪兽是否是装备怪兽。
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 效果①的目标选择函数，设置放置指示物的操作信息。
function c1118137.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为放置1个魔力指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果①的操作执行函数，为这张卡放置1个魔力指示物。
function c1118137.ctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 效果②的数值计算函数，计算并返回这张卡上的魔力指示物数量×500作为攻击力·守备力上升值。
function c1118137.atkval(e,c)
	return e:GetHandler():GetCounter(0x1)*500
end
-- 效果③的破坏代替目标函数，检查装备怪兽是否因战斗或效果被破坏，以及玩家是否能去除1个魔力指示物。
function c1118137.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) and not tg:IsReason(REASON_REPLACE)
		-- 检查自己场上是否存在至少1个魔力指示物可以被去除。
		and Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_EFFECT) end
	-- 提示玩家是否使用去除魔力指示物来代替装备怪兽的破坏。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 效果③的破坏代替操作函数，去除自己场上1个魔力指示物以代替破坏。
function c1118137.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 去除自己场上的1个魔力指示物作为破坏代替。
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_EFFECT+REASON_REPLACE)
end
