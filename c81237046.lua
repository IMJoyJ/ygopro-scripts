--糾罪巧－Archaη.TAIL
-- 效果：
-- ←0 【灵摆】 0→
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：要让场上的卡破坏的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。这个回合中，自己场上的怪兽以及「纠罪巧」魔法卡不会被效果破坏。
-- ③：只要反转过的这张卡在怪兽区域存在，每次怪兽被送去对方墓地，对方受到900伤害。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果并添加自定义特殊召唤计数器
function s.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤与灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x71,LOCATION_PZONE)
	-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：要让场上的卡破坏的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。这个回合中，自己场上的怪兽以及「纠罪巧」魔法卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"抗性赋予"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.indcon)
	e3:SetCost(s.indcost)
	e3:SetTarget(s.indtg)
	e3:SetOperation(s.indop)
	c:RegisterEffect(e3)
	-- ③：只要反转过的这张卡在怪兽区域存在
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- 每次怪兽被送去对方墓地，对方受到900伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.damcon1)
	e5:SetOperation(s.damop1)
	c:RegisterEffect(e5)
	-- 每次怪兽被送去对方墓地，对方受到900伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.regcon)
	e6:SetOperation(s.regop)
	c:RegisterEffect(e6)
	-- 每次怪兽被送去对方墓地，对方受到900伤害。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.damcon2)
	e7:SetOperation(s.damop2)
	c:RegisterEffect(e7)
	-- 添加自定义特殊召唤计数器，用于检测本回合是否特殊召唤过非里侧表示的怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：只允许里侧表示的特殊召唤
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 灵摆效果①的效果处理：给这张卡放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤函数：检索「纠罪巧」卡片
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 灵摆效果②的发动条件：另一边的自己的灵摆区域有「纠罪巧」卡存在
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边的灵摆区域是否存在「纠罪巧」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤函数：比这张卡攻击力低的对方场上的表侧表示怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 灵摆效果②的对象选择与合法性检查
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 检查对方场上是否存在可作为对象的、攻击力比这张卡低的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择并确认要破坏的对方怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置破坏操作的信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果②的效果处理：破坏选择的怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 怪兽效果①的发动成本与誓约限制：展示手卡并注册本回合不能表侧特殊召唤的限制
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合是否未进行过非里侧守备表示的特殊召唤
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- （这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。②：要让场上的卡破坏的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。这个回合中，自己场上的怪兽以及「纠罪巧」魔法卡不会被效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 为玩家注册本回合不能表侧表示特殊召唤怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制函数：禁止表侧表示的特殊召唤
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤函数：可以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽效果①的靶向与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受到不能里侧特殊召唤等相关效果的影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己场上是否有可用的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤操作的信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果①的效果处理：从手卡把1只怪兽里侧守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域已满，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选择的怪兽以里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若该怪兽原本是公开状态，则让对方确认该卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽效果②的发动条件：对方发动破坏场上卡的效果时，且这张卡在场上里侧表示存在
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡是否未被战斗破坏，且对方发动的效果可以被连锁
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 排除对方连锁前一个无效效果而发动的魔法卡发动等特殊情况
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取对方发动效果的破坏操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
		and ep~=tp and e:GetHandler():IsFacedown()
end
-- 怪兽效果②的发动成本：把里侧表示的这张卡变成表侧守备表示
function s.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将这张卡改变为表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 怪兽效果②的靶向与合法性检查
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否尚未适用过此抗性效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- 怪兽效果②的效果处理：注册破坏抗性并记录本回合已发动标记
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，自己场上的怪兽以及「纠罪巧」魔法卡不会被效果破坏。③：只要反转过的这张卡在怪兽区域存在，每次怪兽被送去对方墓地，对方受到900伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTarget(s.indtg2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 注册破坏抗性的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 注册玩家标记，确保该效果每回合只能适用一次
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 抗性适用对象过滤：自己场上的怪兽，以及表侧表示的「纠罪巧」魔法卡
function s.indtg2(e,c)
	return c:IsType(TYPE_MONSTER) or c:IsSetCard(0x1d4) and c:IsType(TYPE_SPELL) and c:IsFaceup()
end
-- 这张卡反转时的处理：注册“已反转过”的标记
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已反转过"
	c:SetStatus(STATUS_EFFECT_ENABLED,true)
end
-- 过滤函数：送去对方墓地的怪兽
function s.damfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 怪兽效果③的发动条件（非连锁处理中）：反转过的这张卡在场，且有怪兽被送去对方墓地
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查是否有怪兽被送去对方墓地，且当前不处于连锁处理中
		and eg:IsExists(s.damfilter,1,nil,1-tp) and not Duel.IsChainSolving()
end
-- 怪兽效果③的效果处理（非连锁处理中）：对方受到900伤害
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 展示卡片发动动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 给与对方900点效果伤害
	Duel.Damage(1-tp,900,REASON_EFFECT)
end
-- 怪兽效果③的延迟触发条件（连锁处理中）：反转过的这张卡在场，且有怪兽在连锁处理中被送去对方墓地
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查是否有怪兽被送去对方墓地，且当前正处于连锁处理中
		and eg:IsExists(s.damfilter,1,nil,1-tp) and Duel.IsChainSolving()
end
-- 怪兽效果③的延迟触发处理：注册一个在连锁处理完毕后触发伤害的标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.damfilter,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(id+o,RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_CHAIN,0,1)
end
-- 怪兽效果③的延迟伤害触发条件：连锁处理完毕且存在延迟伤害标记
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+o)>0
end
-- 怪兽效果③的延迟伤害效果处理：重置标记并给与对方900伤害
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 展示卡片发动动画提示
	Duel.Hint(HINT_CARD,0,id)
	e:GetHandler():ResetFlagEffect(id+o)
	-- 给与对方900点效果伤害
	Duel.Damage(1-tp,900,REASON_EFFECT)
end
