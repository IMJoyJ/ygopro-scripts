--糾罪巧－Aizaβ.LEON
-- 效果：
-- ←0 【灵摆】 0→
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：对方连锁自己的效果的发动把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。场上最多3张卡回到手卡。
-- ③：只要反转过的这张卡在怪兽区域存在，对方每次自身的卡的效果让自身手卡有卡加入，受到每1张900伤害。
local s,id,o=GetID()
-- 初始化卡片效果：注册灵摆属性、灵摆放置指示物、战阶结束破坏怪兽、手牌里侧特召、连锁变表弹卡及反转后手牌增加效果伤害
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
	-- ②：对方连锁自己的效果的发动把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。场上最多3张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回手"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- 注册反转标记效果：此卡反转时赋予已反转过的状态标记
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- ③：只要反转过的这张卡在怪兽区域存在，对方每次自身的卡的效果让自身手卡有卡加入，受到每1张900伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_HAND)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.damcon1)
	e5:SetOperation(s.damop1)
	c:RegisterEffect(e5)
	-- 连锁处理中手牌增加记录效果：在连锁处理期间记录对方加入手牌的卡片数量
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TO_HAND)
	e6:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.regcon)
	e6:SetOperation(s.regop)
	c:RegisterEffect(e6)
	-- 连锁结算后伤害结算效果：在连锁结算结束后根据记录的卡片数量结算伤害
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.damcon2)
	e7:SetOperation(s.damop2)
	c:RegisterEffect(e7)
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
-- 灵摆区过滤条件：「纠罪巧」卡
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 灵摆破坏效果条件：另一个灵摆区域存在「纠罪巧」卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己另一个灵摆区域是否存在「纠罪巧」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 破坏过滤条件：对方场上表侧表示且攻击力低于此卡原本攻击力的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 灵摆破坏效果准备：选择对方场上1只攻击力较低的怪兽为对象并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 发动条件检查：对方场上是否存在攻击力小于此卡原本攻击力的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置连锁操作信息：破坏目标怪兽1只
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆破坏效果处理：破坏目标怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁设定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽破坏
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
-- 手牌特召效果准备：检查特殊召唤限制与可用区域
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
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗混手牌
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
-- 连锁变表弹卡条件：对方连锁己方效果发动，且此卡为里侧表示
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取上一连锁的效果与发动玩家
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:GetHandlerPlayer()==tp and ep~=tp and e:GetHandler():IsFacedown()
end
-- 连锁变表弹卡Cost：把里侧表示的此卡变成表侧守备表示
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将自身变更表示形式为表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 连锁变表弹卡准备：设置弹回手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可返回手牌的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置连锁操作信息：将卡片返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 连锁变表弹卡处理：选择场上最多3张卡回到手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1~3张卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Select(tp,1,3,nil)
	if #g>0 then
		-- 高亮显示选择的目标卡片
		Duel.HintSelection(g)
		-- 将选中的卡送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 反转效果处理：注册已反转标记
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已反转过"
	c:SetStatus(STATUS_EFFECT_ENABLED,true)
end
-- 非连锁加手伤害条件：已反转过且对方因自身效果非连锁加手
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查是否有对方的卡加入对方手牌且不在连锁结算中
		and eg:IsExists(Card.IsControler,1,nil,1-tp) and not Duel.IsChainSolving()
		and re and re:GetOwnerPlayer()==1-tp
end
-- 非连锁加手伤害处理：根据加入对方手牌的卡片数量给予伤害
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动提示
	Duel.Hint(HINT_CARD,0,id)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	-- 给予对方加入手牌张数×900的效果伤害
	Duel.Damage(1-tp,ct*900,REASON_EFFECT)
end
-- 连锁中加手记录条件：已反转过且对方在连锁结算中因效果加手
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查是否有对方的卡在连锁结算中加入对方手牌
		and eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.IsChainSolving()
		and re and re:GetOwnerPlayer()==1-tp
end
-- 连锁中加手记录处理：注册FlagEffect记录增加的卡片数量
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(id+o,RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_CHAIN,0,1,ct)
end
-- 连锁后伤害结算条件：存在连锁中记录的加手FlagEffect
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+o)>0
end
-- 连锁后伤害结算处理：统计记录的张数并计算伤害
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动提示
	Duel.Hint(HINT_CARD,0,id)
	local labels={e:GetHandler():GetFlagEffectLabel(id+o)}
	local ct=0
	for i=1,#labels do ct=ct+labels[i] end
	e:GetHandler():ResetFlagEffect(id+o)
	-- 给予对方累计记录张数×900的效果伤害
	Duel.Damage(1-tp,ct*900,REASON_EFFECT)
end
