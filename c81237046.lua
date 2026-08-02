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
-- 初始化函数，添加相关效果
function s.initial_effect(c)
	-- 添加灵摆怪兽属性
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
	-- ③：只要反转过的这张卡在怪兽区域存在，每次怪兽被送去对方墓地，对方受到900伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- ③：只要反转过的这张卡在怪兽区域存在，每次怪兽被送去对方墓地，对方受到900伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.damcon1)
	e5:SetOperation(s.damop1)
	c:RegisterEffect(e5)
	-- ③：只要反转过的这张卡在怪兽区域存在，每次怪兽被送去对方墓地，对方受到900伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.regcon)
	e6:SetOperation(s.regop)
	c:RegisterEffect(e6)
	-- ③：只要反转过的这张卡在怪兽区域存在，每次怪兽被送去对方墓地，对方受到900伤害。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.damcon2)
	e7:SetOperation(s.damop2)
	c:RegisterEffect(e7)
	-- 为玩家设置特殊召唤相关操作的计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 特殊召唤计数器的过滤条件
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 灵摆效果①的处理逻辑：放置指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤条件：名字带有「纠罪巧」的卡
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 灵摆效果②的发动条件
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边的自己的灵摆区域是否有「纠罪巧」卡存在
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤条件：比这张卡攻击力低的表侧表示怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 灵摆效果②的目标设置
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 检查是否有可以作为对象的对方场上的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只比这张卡攻击力低的对方场上的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置操作信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果②的处理逻辑
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 如果怪兽在场则将其破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 怪兽效果①的代价和条件
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查玩家本回合是否特殊召唤过其他形式的怪兽且这张卡没有公开
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将该限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果：检查是否为非里侧守备表示的特殊召唤
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤条件：可以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽效果①的目标设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 如果玩家受到光之护封剑等效果影响，则不能发动
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查是否有可以特殊召唤怪兽的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否有可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果①的处理逻辑
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果没有可以特殊召唤怪兽的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只可以特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 手动洗切手卡
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选中的怪兽里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 如果是展示的卡，给对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽效果②的发动条件
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果这张卡在战斗中被破坏，或者连锁不能被无效，则不能发动
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 如果对方发动的包含无效效果且为魔法陷阱卡的发动，则不能发动
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取连锁中的破坏效果信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
		and ep~=tp and e:GetHandler():IsFacedown()
end
-- 怪兽效果②的代价
function s.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把里侧表示的这张卡变成表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 怪兽效果②的目标设置
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否发动过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- 怪兽效果②的处理逻辑：赋予不会被效果破坏的抗性
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：要让场上的卡破坏的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。这个回合中，自己场上的怪兽以及「纠罪巧」魔法卡不会被效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTarget(s.indtg2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将赋予抗性的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
	-- 将发动过此效果的标识注册给玩家
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 抗性赋予过滤条件：怪兽或者「纠罪巧」魔法卡
function s.indtg2(e,c)
	return c:IsType(TYPE_MONSTER) or c:IsSetCard(0x1d4) and c:IsType(TYPE_SPELL) and c:IsFaceup()
end
-- 添加是否反转过的标识效果处理逻辑
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已反转过"
	c:SetStatus(STATUS_EFFECT_ENABLED,true)
end
-- 过滤条件：控制者为该玩家的怪兽
function s.damfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 怪兽效果③的不入连锁伤害触发条件
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查是否有怪兽送去对方墓地，且当前没有正在处理连锁
		and eg:IsExists(s.damfilter,1,nil,1-tp) and not Duel.IsChainSolving()
end
-- 怪兽效果③的不入连锁伤害处理逻辑
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示卡片发动
	Duel.Hint(HINT_CARD,0,id)
	-- 给与对方900伤害
	Duel.Damage(1-tp,900,REASON_EFFECT)
end
-- 怪兽效果③的入连锁伤害记录条件
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查是否有怪兽送去对方墓地，且当前正在处理连锁
		and eg:IsExists(s.damfilter,1,nil,1-tp) and Duel.IsChainSolving()
end
-- 怪兽效果③的入连锁伤害记录逻辑
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.damfilter,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(id+o,RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_CHAIN,0,1)
end
-- 怪兽效果③的入连锁伤害触发条件
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+o)>0
end
-- 怪兽效果③的入连锁伤害处理逻辑
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示卡片发动
	Duel.Hint(HINT_CARD,0,id)
	e:GetHandler():ResetFlagEffect(id+o)
	-- 给与对方900伤害
	Duel.Damage(1-tp,900,REASON_EFFECT)
end
