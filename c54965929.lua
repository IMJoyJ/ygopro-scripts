--魔導獣 メデューサ
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合，以自己墓地1只可以放置魔力指示物的怪兽为对象才能发动。这张卡破坏，那只怪兽特殊召唤，给那只怪兽放置1个魔力指示物。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：1回合1次，自己·对方的战斗阶段，把自己场上2个魔力指示物取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成一半。
function c54965929.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）。
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域没有卡存在的场合，以自己墓地1只可以放置魔力指示物的怪兽为对象才能发动。这张卡破坏，那只怪兽特殊召唤，给那只怪兽放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54965929,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,54965929)
	e1:SetCondition(c54965929.spcon)
	e1:SetTarget(c54965929.sptg)
	e1:SetOperation(c54965929.spop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 设置效果处理为：在连锁发生时，在自身卡片上注册一个正在连锁的标记（用于后续判定魔法卡发动是否成功）。
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c54965929.acop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己·对方的战斗阶段，把自己场上2个魔力指示物取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54965929,1))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetHintTiming(TIMING_DAMAGE_STEP)
	e4:SetCondition(c54965929.atkcon)
	e4:SetCost(c54965929.atkcost)
	e4:SetTarget(c54965929.atktg)
	e4:SetOperation(c54965929.atkop)
	c:RegisterEffect(e4)
end
-- 灵摆效果的发动条件判定函数（另一边的自己的灵摆区域没有卡存在）。
function c54965929.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边的自己的灵摆区域是否存在卡片，若没有则返回true。
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤函数：筛选自己墓地中可以放置魔力指示物、且可以特殊召唤的怪兽。
function c54965929.spfilter(c,e,tp)
	-- 检查卡片是否可以放置魔力指示物、玩家是否能为其添加1个魔力指示物，以及是否可以特殊召唤。
	return c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果的发动准备（靶向/目标选择与可行性检查）函数。
function c54965929.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c54965929.spfilter(chkc,e,tp) end
	-- 检查自身是否可以被破坏，以及自己场上是否有可用的怪兽区域空格。
	if chk==0 then return c:IsDestructable() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤和放置魔力指示物条件的怪兽。
		and Duel.IsExistingTarget(c54965929.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足条件的怪兽作为效果的对象并将其设为效果目标。
	local g=Duel.SelectTarget(tp,c54965929.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：包含破坏自身卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置连锁操作信息：包含特殊召唤目标怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 灵摆效果的处理函数（破坏自身，特殊召唤目标怪兽并放置魔力指示物）。
function c54965929.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并执行破坏自身的操作，若成功破坏则继续处理。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 获取本次效果发动的目标怪兽（即墓地中选择的怪兽）。
		local tc=Duel.GetFirstTarget()
		-- 检查目标怪兽是否仍与效果相关，并将其以表侧表示特殊召唤到自己场上，若特殊召唤成功则继续处理。
		if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsCanAddCounter(0x1,1) then
			tc:AddCounter(0x1,1)
		end
	end
end
-- 每次魔法卡发动时，给自身放置魔力指示物的效果处理函数。
function c54965929.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 怪兽效果②的发动条件判定函数（自己或对方的战斗阶段，且不在伤害计算后）。
function c54965929.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否处于战斗阶段（从战斗阶段开始到战斗阶段结束）。
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		-- 检查当前是否不处于伤害计算后（确保可以在伤害步骤的合适时机发动）。
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 怪兽效果②的发动代价（Cost）处理函数（移去自己场上2个魔力指示物）。
function c54965929.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检查阶段，判定自己场上是否能移去2个魔力指示物作为代价。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 移去自己场上2个魔力指示物作为发动的代价。
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 怪兽效果②的发动准备（选择场上1只表侧表示怪兽作为对象）函数。
function c54965929.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示的怪兽可以作为效果的对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的怪兽作为效果的对象并将其设为效果目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 怪兽效果②的效果处理函数（使目标怪兽的攻击力·守备力直到回合结束时变成一半）。
function c54965929.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的守备力直到回合结束时变成一半。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
