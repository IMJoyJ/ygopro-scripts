--魔導獣 メデューサ
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合，以自己墓地1只可以放置魔力指示物的怪兽为对象才能发动。这张卡破坏，那只怪兽特殊召唤，给那只怪兽放置1个魔力指示物。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：1回合1次，自己·对方的战斗阶段，把自己场上2个魔力指示物取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成一半。
function c54965929.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡发动并进行灵摆召唤
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
	-- 每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 用aux.chainreg记录在效果发动（连锁发生）时这张卡在怪兽区域存在，为后续放置魔力指示物的处理提供在场判定标记
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
c54965929.mentioned_counter={
	[0x1]=true,
}
-- 灵摆效果的发动条件函数：判断另一边的自己的灵摆区域是否没有卡存在
function c54965929.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域中除这张卡以外是否存在其他卡，不存在则满足发动条件
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 特殊召唤对象的过滤函数：筛选可以放置魔力指示物且可以被特殊召唤的怪兽
function c54965929.spfilter(c,e,tp)
	-- 该卡可以放置魔力指示物、当前可以向其添加1个魔力指示物，并且满足被这个效果特殊召唤的条件
	return c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果的对象选择函数：先校验连锁对象，再检查效果能否发动
function c54965929.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c54965929.spfilter(chkc,e,tp) end
	-- 效果可发动的前提检查：这张卡自身可以被效果破坏，且自己的主要怪兽区域有空位
	if chk==0 then return c:IsDestructable() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在可以放置魔力指示物并能成为效果对象的可特殊召唤怪兽
		and Duel.IsExistingTarget(c54965929.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54965929.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：宣言这个连锁将破坏这张卡自身（1张）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置操作信息：宣言这个连锁将把对象的那1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 灵摆效果的处理函数：破坏这张卡，将对象怪兽特殊召唤并放置魔力指示物
function c54965929.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果相关联，则以效果将其破坏，破坏成功才继续后续处理
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 取得当前连锁的对象卡（墓地选择的那只怪兽）
		local tc=Duel.GetFirstTarget()
		-- 若对象怪兽仍与效果相关联，则将其以表侧表示特殊召唤到自己场上，且特殊召唤成功
		if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsCanAddCounter(0x1,1) then
			tc:AddCounter(0x1,1)
		end
	end
end
-- 放置魔力指示物的处理：若处理的是魔法卡的发动，且这张卡在连锁发生时被标记为在场上存在，则给这张卡放置1个魔力指示物
function c54965929.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 攻击力减半效果的发动条件函数：限定在自己或对方的战斗阶段且非伤害计算后
function c54965929.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段处于战斗阶段（战斗阶段开始至战斗阶段结束之间）
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		-- 并且当前不在伤害步骤的伤害计算之后（满足伤害步骤的发动限制）
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 攻击力减半效果的代价函数：确认并执行把自己场上2个魔力指示物取除
function c54965929.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动代价的可行性检查：自己场上是否存在可以取除的2个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 作为发动代价，把自己场上2个魔力指示物取除
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 攻击力减半效果的对象选择函数：以场上1只表侧表示怪兽为对象
function c54965929.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果可发动的前提检查：双方怪兽区域是否存在可以成为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让自己选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 攻击力减半效果的处理：让对象怪兽的攻击力·守备力各自变成一半（向上取整），直到回合结束时适用
function c54965929.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 守备力直到回合结束时变成一半。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
