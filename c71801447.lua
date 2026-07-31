--糾罪巧－Atilε.SPIA
-- 效果：
-- ←0 【灵摆】 0→
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：对方在连锁3以后把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。这个效果的发动时积累的连锁上的全部对方的效果的发动无效并破坏。
-- ③：只要反转过的这张卡在怪兽区域存在，对方不能对应自身的卡的效果的发动把卡的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果：注册灵摆属性、指示物放置、战阶结束破坏对方怪兽、手牌里侧特召及誓约、连锁3以上反转无效连锁破坏、反转后封锁对方响应效果
function s.initial_effect(c)
	-- 启用灵摆卡的基本属性与发动画框
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
	-- ②：对方在连锁3以后把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。这个效果的发动时积累的连锁上的全部对方的效果的发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"效果无效"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	-- ③：只要反转过的这张卡在怪兽区域存在，对方不能对应自身的卡的效果的发动把卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- ③：只要反转过的这张卡在怪兽区域存在，对方不能对应自身的卡的效果的发动把卡的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.chainop)
	c:RegisterEffect(e5)
	-- 注册自定义活动计数器：追踪本回合玩家非里侧守备表示特殊召唤怪兽的记录
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤条件：检查特殊召唤的怪兽是否为里侧表示
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 放置指示物处理：给此卡放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 灵摆区域卡片过滤条件：「纠罪巧」系列卡片
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 灵摆破坏效果条件：另一边的己方灵摆区域存在「纠罪巧」卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边的己方灵摆区域是否存在「纠罪巧」卡片
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 破坏对象过滤条件：对方场上表侧表示且攻击力低于此卡原本攻击力的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 灵摆破坏效果准备：选择比此卡攻击力低的对方怪兽为对象，并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 检查对方场上是否存在攻击力低于此卡的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只攻击力低于此卡的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置连锁操作信息：破坏选中的目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆破坏效果处理：破坏选中的对方怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 手牌特召效果Cost：展示手牌的此卡，并注册本回合不能非里侧特召的誓约约束
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- Cost检查：此卡未公开且本回合未进行过非里侧表示的特殊召唤
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 为玩家注册本回合特殊召唤表示形式限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制条件：禁止以表侧表示特殊召唤怪兽
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 手牌特召过滤条件：可以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 手牌特召效果准备：检查特殊召唤限制与可用区域，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查是否受神圣之光等禁止里侧表示设置的效果影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查主要怪兽区域是否有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在可里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 手牌特召效果处理：从手牌选1只怪兽里侧守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 怪兽区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗混己方手牌
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选中怪兽以里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若特召怪兽此前公开过，特召后向对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 控制卡片过滤条件：己方场上的卡片
function s.ccfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
-- 无效效果触发条件：此卡为里侧表示，且对方在连锁3以后发动了效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or rp~=1-tp then return false end
	if not c:IsFacedown() then return false end
	for i=1,ev do
		-- 获取连锁上指定节点的引发玩家
		local tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_PLAYER)
		-- 检查连锁节点是否由对方发动且可被无效
		if tgp~=tp and Duel.IsChainNegatable(i) then
			-- 判断当前连锁数是否在3以上
			return Duel.GetCurrentChain()>2
		end
	end
	return false
end
-- 无效效果Cost：把里侧表示的此卡变成表侧守备表示
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将自身表示形式变更表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 无效效果发动准备：收集连锁上所有对方发动的效果与卡片，并设置无效与破坏操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取连锁节点对应的触发效果与引发玩家
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		-- 检查该连锁节点是否由对方发动且可被无效
		if tgp~=tp and Duel.IsChainNegatable(i) then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	-- 将要破坏的对方卡片组设为连锁影响目标
	Duel.SetTargetCard(dg)
	-- 设置连锁操作信息：无效对方全部效果的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,ng:GetCount(),0,0)
	-- 设置连锁操作信息：破坏被无效发动的全部卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 无效效果处理：将当前连锁上对方发动的效果全部无效并破坏
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取连锁节点对应的触发效果与引发玩家
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		-- 若节点由对方发动，将其效果的发动无效
		if tgp~=tp and Duel.NegateActivation(i) then
			local tc=te:GetHandler()
			if tc:IsRelateToEffect(e) and tc:IsRelateToChain(i) then
				dg:AddCard(tc)
			end
		end
	end
	-- 破坏被无效发动的全部卡片
	Duel.Destroy(dg,REASON_EFFECT)
end
-- 反转事件处理：给此卡注册反转过标记 Flag
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已反转过"
	c:SetStatus(STATUS_EFFECT_ENABLED,true)
end
-- 连锁响应限制条件：反转过的此卡在场，对方发动效果时限制对方无法响应自身卡片
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==1-tp and c:GetFlagEffect(id)>0 then
		-- 设置连锁响应限制规则
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制判断：禁止对方对应自身的卡的效果发动连锁
function s.chainlm(e,rp,tp)
	return tp==rp
end
