--ガーディアンの力
-- 效果：
-- ①：装备怪兽进行战斗的攻击宣言时发动。给这张卡放置1个魔力指示物。
-- ②：装备怪兽的攻击力·守备力上升这张卡的魔力指示物数量×500。
-- ③：装备怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个魔力指示物取除。
function c1118137.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 装备魔法的发动：以场上1只表侧表示怪兽为对象，把这张卡作为装备卡装备给它
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
	-- ②：装备怪兽的攻击力上升这张卡的魔力指示物数量×500。
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
	-- 装备对象的限制：这张卡只能作为装备卡装备给1只怪兽（装备魔法的基本装备规则）
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
-- 发动时以双方怪兽区域1只表侧表示怪兽为对象作为装备对象，并设置把这张卡装备给它的操作信息
function c1118137.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查双方怪兽区域是否存在可以成为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示：“请选择要装备的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择双方怪兽区域1只表侧表示怪兽作为装备对象并设为连锁对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁把这张卡作为装备卡装备（CATEGORY_EQUIP，数量1）
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取得对象怪兽，若这张卡和对象怪兽都仍与效果关联且对象表侧表示，则把这张卡装备给它
function c1118137.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（要装备的怪兽）
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 把这张卡作为装备卡装备给对象怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 发动条件：判断进行攻击宣言的攻击方或攻击对象是否为装备怪兽（即装备怪兽进行战斗的攻击宣言时）
function c1118137.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 攻击宣言的攻击方或攻击对象是装备怪兽时返回真
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 对象函数：必发效果无需确认，设置操作信息为给这张卡放置1个魔力指示物
function c1118137.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：给这张卡放置1个魔力指示物（CATEGORY_COUNTER）
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果处理：若这张卡仍与效果关联，给这张卡放置1个魔力指示物
function c1118137.ctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 攻击力上升数值：这张卡的魔力指示物数量×500（守备力上升效果复用同一函数）
function c1118137.atkval(e,c)
	return e:GetHandler():GetCounter(0x1)*500
end
-- 代替破坏的对象函数：装备怪兽被战斗·效果破坏且本次破坏尚未被代替时，检查能否取除1个魔力指示物作为代替
function c1118137.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) and not tg:IsReason(REASON_REPLACE)
		-- 并且能以效果原因取除自己场上1个魔力指示物
		and Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_EFFECT) end
	-- 询问玩家是否取除1个魔力指示物来代替装备怪兽的破坏
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 效果处理：取除自己场上1个魔力指示物，代替装备怪兽的破坏
function c1118137.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果·代替破坏为原因取除自己场上1个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_EFFECT+REASON_REPLACE)
end
