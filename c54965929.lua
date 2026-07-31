--魔導獣 メデューサ
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合，以自己墓地1只可以放置魔力指示物的怪兽为对象才能发动。这张卡破坏，那只怪兽特殊召唤，给那只怪兽放置1个魔力指示物。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：1回合1次，自己·对方的战斗阶段，把自己场上2个魔力指示物取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成一半。
function c54965929.initial_effect(c)
	-- 注册灵摆怪兽属性与灵摆召唤
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- 另一边的自己的灵摆区域没有卡存在的场合，以自己墓地1只可以放置魔力指示物的怪兽为对象才能发动。这张卡破坏，那只怪兽特殊召唤，给那只怪兽放置1个魔力指示物。
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
	-- 注册连锁检测标记
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 在连锁发生时记录此卡在场
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c54965929.acop)
	c:RegisterEffect(e3)
	-- 1回合1次，自己·对方的战斗阶段，把自己场上2个魔力指示物取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成一半。
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
c54965929.mentioned_counter={
	[0x1]=true,
}
-- 灵摆效果的发动条件判断
function c54965929.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边的灵摆区域是否没有卡
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤墓地中可放置魔力指示物且能特招的怪兽
function c54965929.spfilter(c,e,tp)
	-- 判断墓地怪兽是否可以放置魔力指示物且可以特殊召唤
	return c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果的目标与分类设置
function c54965929.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c54965929.spfilter(chkc,e,tp) end
	-- 检查自身是否可被破坏且怪兽区有空位
	if chk==0 then return c:IsDestructable() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c54965929.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c54965929.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置连锁操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 灵摆效果的处理
function c54965929.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 自身破坏成功时继续处理
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 获取特招的目标怪兽
		local tc=Duel.GetFirstTarget()
		-- 将选择的墓地怪兽特殊召唤
		if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsCanAddCounter(0x1,1) then
			tc:AddCounter(0x1,1)
		end
	end
end
-- 魔法卡结算成功时增加魔力指示物
function c54965929.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 降攻效果的发动条件判断
function c54965929.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为战斗阶段
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		-- 判断是否不在伤害计算中
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 降攻效果的Cost处理
function c54965929.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有至少2个魔力指示物可以取除
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 取除自己场上2个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 降攻效果的目标与分类设置
function c54965929.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 降攻效果的处理
function c54965929.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时变成一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的守备力直到回合结束时变成一半
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
