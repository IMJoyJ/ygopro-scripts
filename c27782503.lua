--六武衆－イロウ
-- 效果：
-- 自己场上有「六武众-伊郎」以外的名字带有「六武众」的怪兽存在，这张卡向里侧守备表示怪兽攻击的场合，不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
function c27782503.initial_effect(c)
	-- 效果原文：自己场上有「六武众-伊郎」以外的名字带有「六武众」的怪兽存在，这张卡向里侧守备表示怪兽攻击的场合，不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27782503,0))  --"里侧守备的攻击对象怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c27782503.descon)
	e1:SetTarget(c27782503.destg)
	e1:SetOperation(c27782503.desop)
	c:RegisterEffect(e1)
	-- 效果原文：此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c27782503.desreptg)
	e2:SetOperation(c27782503.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在名字带有「六武众」且不是伊郎的表侧表示怪兽
function c27782503.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(27782503)
end
-- 效果条件：确认攻击怪兽是自己，攻击目标是里侧守备表示怪兽，并且自己场上有其他六武众怪兽
function c27782503.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 判断攻击怪兽是否为自身，且攻击目标为里侧守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
		-- 判断自己场上是否存在其他六武众怪兽
		and Duel.IsExistingMatchingCard(c27782503.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置破坏效果的目标为攻击目标怪兽
function c27782503.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断攻击目标是否与战斗相关
	if chk==0 then return Duel.GetAttackTarget():IsRelateToBattle() end
	-- 设置连锁操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 执行破坏操作，将攻击目标怪兽破坏
function c27782503.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 代替破坏的过滤函数：检查场上名字带有「六武众」且可被破坏的表侧表示怪兽
function c27782503.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的触发条件：确认自身在场且表侧表示，并且存在可代替破坏的六武众怪兽
function c27782503.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查场上是否存在可代替破坏的六武众怪兽
		and Duel.IsExistingMatchingCard(c27782503.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择代替破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择场上满足条件的六武众怪兽作为代替破坏对象
		local g=Duel.SelectMatchingCard(tp,c27782503.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 执行代替破坏操作，将选中的怪兽破坏
function c27782503.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的怪兽以效果和代替原因破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
