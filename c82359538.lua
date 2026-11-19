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
-- 初始化灵摆怪兽属性及指示物容纳，依次注册灵摆区的①放置指示物和②破坏对方低攻怪兽效果，以及怪兽区的①展示并里侧特召、②连锁反转弹卡和③反转后对方检索烧血监听效果与特殊召唤限制计数器
function s.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽的基础属性与灵摆卡发动、灵摆召唤能力
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
	-- 【怪兽效果】①：把手卡的这张卡给对方观看才能发动
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
	-- 只要反转过的这张卡在怪兽区域存在，
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- 对方每次自身的卡的效果让自身手卡有卡加入，受到每1张900伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_HAND)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.damcon1)
	e5:SetOperation(s.damop1)
	c:RegisterEffect(e5)
	-- 对方每次自身的卡的效果让自身手卡有卡加入，
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TO_HAND)
	e6:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.regcon)
	e6:SetOperation(s.regop)
	c:RegisterEffect(e6)
	-- 受到每1张900伤害。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.damcon2)
	e7:SetOperation(s.damop2)
	c:RegisterEffect(e7)
	-- 注册自定义行动计数器，追踪玩家本回合是否以表侧表示进行过特殊召唤
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 自定义行动计数器过滤函数：返回卡片是否为里侧表示（非里侧表示则使计数器计数）
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 执行灵摆①效果处理：每当场上有怪兽反转时，给处于灵摆区域的这张卡放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤卡片是否属于「纠罪巧」字段
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 检查灵摆②效果的发动条件：自己另一侧的灵摆区域是否存在「纠罪巧」卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查除这张卡之外自己的灵摆区域是否存在至少1张「纠罪巧」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤可作为灵摆②效果对象的对方怪兽：须为表侧表示且当前攻击力低于这张卡的攻击力
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 获取这张卡的攻击力并检查重选对象时的有效性：对象须位于对方怪兽区且攻击力低于这张卡攻击力
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 检查对方怪兽区是否存在至少1只攻击力低于这张卡的表侧表示怪兽可成为对象
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 向发动玩家发送选择要破坏的卡片提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动玩家从对方怪兽区选择1只满足条件的怪兽作为本次连锁的对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 登记本次连锁包含破坏对象怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行灵摆②效果处理：若对象怪兽仍与当前连锁关联且仍为怪兽，将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选中的对方场上对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 以效果破坏对象怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 怪兽①效果代价检查：确认手卡中的这张卡当前未公开，且发动玩家本回合未曾以表侧表示特殊召唤过怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查玩家本回合内是否尚未进行过非里侧表示的特殊召唤
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- （这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 为自己注册持续到回合结束时的特殊召唤表示形式限制效果（誓约）
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤表示形式限制过滤函数：禁止以表侧表示特殊召唤怪兽
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤手卡中可被怪兽①效果特殊召唤的怪兽：检查能否以里侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽①效果的发动检查与信息设置：确认不受禁止里侧表示效果影响、怪兽区有空位且手卡有可里侧守备特召的怪兽，登记从手卡特殊召唤1只怪兽的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查发动玩家是否受到“不能里侧表示放置/特殊召唤”的效果（如神圣之光）影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己主要怪兽区是否还有至少1个可用空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在至少1只能够里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次连锁包含从自己手卡特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行怪兽①效果处理：确认怪兽区有空位后，从手卡选择1只怪兽里侧守备表示特殊召唤并洗切手卡；若所选怪兽原处于公开状态，特殊召唤后需给对方确认
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否已无空位，若无则中止特殊召唤处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动玩家发送选择要特殊召唤的卡片提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己手卡中选择1只可里侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切发动玩家的手卡以掩盖里侧特殊召唤卡片的来源位置信息
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选出的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若所选怪兽原本在手卡中处于公开状态，将其展示给对方确认以核验合法性
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 检查怪兽②效果的发动条件：当前连锁序号不小于2，上一连锁由自己发动、当前连锁由对方发动，且怪兽区的这张卡当前为里侧表示
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 then return false end
	-- 获取前一个连锁的效果与发动玩家信息
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and p==tp and ep~=tp and e:GetHandler():IsFacedown()
end
-- 怪兽②效果的发动代价：将里侧表示的这张卡翻开变为表侧守备表示
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将作为代价的这张卡表示形式变更为表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 怪兽②效果的发动检查与信息设置：确认双方场上存在至少1张可回到手卡的卡片，并登记回手操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上所有能够返回手卡的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 登记本次连锁包含将场上卡片返回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行怪兽②效果处理：从双方场上选择1~3张可回手的卡片，提示选定动画后将其以效果返回手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家发送选择要返回手卡的卡片提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让发动玩家从双方场上所有可回手卡中选择1至3张卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Select(tp,1,3,nil)
	if #g>0 then
		-- 向双方玩家展示被选中准备返回手卡的卡片提示动画
		Duel.HintSelection(g)
		-- 将选出的场上卡片以效果返回各自持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 反转时辅助处理：为这张卡注册“已反转过”的标记和客户端提示，并确保卡的永续效果状态已启用
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已反转过"
	c:SetStatus(STATUS_EFFECT_ENABLED,true)
end
-- 检查③效果即时烧血条件：这张卡带有已反转标记、有卡加入对方手卡、当前不处于连锁处理中且加入原因是由对方玩家自己的卡效果引起
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查加入手卡的卡片中是否有对方控制的卡，且当前不处于连锁结算过程中
		and eg:IsExists(Card.IsControler,1,nil,1-tp) and not Duel.IsChainSolving()
		and re and re:GetOwnerPlayer()==1-tp
end
-- 执行③效果非连锁中烧血处理：提示本卡效果适用动画，统计加入对方手卡的卡片数量并给与对方每张900点效果伤害
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片效果适用的提示动画（不入连锁处理提示）
	Duel.Hint(HINT_CARD,0,id)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	-- 以效果给与对方玩家加入手卡数量乘以900点的伤害
	Duel.Damage(1-tp,ct*900,REASON_EFFECT)
end
-- 检查③效果连锁中暂存计数条件：这张卡带有已反转标记、有卡加入对方手卡、当前正处于连锁处理中且由对方卡效果引起
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查加入手卡的卡片中是否有对方控制的卡，且当前正处于连锁结算过程中
		and eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.IsChainSolving()
		and re and re:GetOwnerPlayer()==1-tp
end
-- 连锁结算中暂存处理：统计本次事件加入对方手卡的卡片数量并记录在当前连锁重置的标记中，待连锁结算完毕后统一给予伤害
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(id+o,RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_CHAIN,0,1,ct)
end
-- 检查③效果连锁结束结算条件：确认这张卡上存在待结算的对方加手数量暂存标记
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+o)>0
end
-- 执行③效果连锁结束统一烧血处理前段：显示卡片提示动画并汇总当前连锁期间记录的全部对方加手卡片总数
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片效果适用的提示动画（不入连锁处理提示）
	Duel.Hint(HINT_CARD,0,id)
	local labels={e:GetHandler():GetFlagEffectLabel(id+o)}
	local ct=0
	for i=1,#labels do ct=ct+labels[i] end
	e:GetHandler():ResetFlagEffect(id+o)
	-- 以效果给与对方玩家累计加入手卡数量乘以900点的伤害
	Duel.Damage(1-tp,ct*900,REASON_EFFECT)
end
