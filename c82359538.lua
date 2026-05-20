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
-- 注册卡片效果的初始化函数，包含灵摆属性、指示物放置、灵摆效果、怪兽效果以及特殊召唤限制计数器。
function s.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤与灵摆卡发动规则。
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
	-- 只要反转过的这张卡在怪兽区域存在
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- ③：只要反转过的这张卡在怪兽区域存在，对方每次自身的卡的效果让自身手卡有卡加入，受到每1张900伤害。（非连锁处理时）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_HAND)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.damcon1)
	e5:SetOperation(s.damop1)
	c:RegisterEffect(e5)
	-- ③：只要反转过的这张卡在怪兽区域存在，对方每次自身的卡的效果让自身手卡有卡加入，受到每1张900伤害。（连锁处理中，注册伤害标记）
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TO_HAND)
	e6:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.regcon)
	e6:SetOperation(s.regop)
	c:RegisterEffect(e6)
	-- ③：只要反转过的这张卡在怪兽区域存在，对方每次自身的卡的效果让自身手卡有卡加入，受到每1张900伤害。（连锁处理完毕时，结算伤害）
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.damcon2)
	e7:SetOperation(s.damop2)
	c:RegisterEffect(e7)
	-- 注册自定义特殊召唤计数器，用于检测本回合是否特殊召唤过里侧表示以外的怪兽。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，仅允许特殊召唤里侧表示的怪兽。
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 灵摆效果①的放置指示物操作，每次怪兽反转时给这张卡放置1个纠罪指示物。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤函数，检查是否为「纠罪巧」字段的卡片。
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 灵摆效果②的条件判断函数，检查另一边的灵摆区域是否存在「纠罪巧」卡片。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己另一边的灵摆区域是否存在「纠罪巧」卡片。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤函数，筛选对方场上表侧表示且攻击力低于指定数值（此卡原本攻击力）的怪兽。
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 灵摆效果②的对象选择与发动准备函数，获取此卡原本攻击力并确认是否有合法的破坏对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 效果发动时的可行性检查，判断对方场上是否存在比这张卡原本攻击力低的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只攻击力低于此卡原本攻击力的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置连锁信息，表示该效果的处理包含破坏选定卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果②的破坏处理函数，将作为对象的怪兽破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 因效果将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 怪兽效果①的Cost与誓约限制函数，展示手卡的此卡，并注册本回合不能表侧特殊召唤怪兽的誓约。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合自己是否进行过里侧守备表示以外的特殊召唤。
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册本回合只能里侧守备表示特殊召唤怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的表示形式，禁止进行表侧表示的特殊召唤。
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤函数，筛选手卡中可以里侧守备表示特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽效果①的发动准备函数，检查怪兽区域空格以及手卡中是否有可里侧特殊召唤的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受到无法里侧特殊召唤的效果影响（如「神圣之光」）。
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己场上是否有可用的怪兽区域空格。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以里侧守备表示特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果的处理包含从手卡特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果①的特殊召唤处理函数，将手卡1只怪兽里侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域空格，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足特殊召唤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切玩家的手卡（重置手卡观看状态）。
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选定的怪兽以里侧守备表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若被特殊召唤的怪兽原本是公开状态，则向对方玩家确认该卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽效果②的发动条件判断函数，检查对方是否连锁自己发动的效果，且此卡处于里侧表示。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取上一个连锁（即对方连锁前自己发动的效果）的效果和发动玩家。
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:GetHandlerPlayer()==tp and ep~=tp and e:GetHandler():IsFacedown()
end
-- 怪兽效果②的Cost处理函数，将里侧表示的此卡变成表侧守备表示。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将此卡变为表侧守备表示。
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 怪兽效果②的发动准备函数，确认场上是否存在可以返回手牌的卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可以返回手牌的卡片。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置连锁信息，表示该效果的处理包含将卡片送回手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 怪兽效果②的返回手牌处理函数，选择场上最多3张卡返回持有者手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择场上1到3张可以返回手牌的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Select(tp,1,3,nil)
	if #g>0 then
		-- 选中卡片时在场上显示被选中的动画效果。
		Duel.HintSelection(g)
		-- 将选中的卡片送回持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 此卡反转时，注册“已反转过”的标记，并使该状态在场上持续生效。
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已反转过"
	c:SetStatus(STATUS_EFFECT_ENABLED,true)
end
-- 怪兽效果③的伤害触发条件（非连锁处理中），检查此卡是否反转过，且对方因自身卡的效果将卡加入手牌。
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查加入手牌的卡是否属于对方，且当前不处于连锁处理中。
		and eg:IsExists(Card.IsControler,1,nil,1-tp) and not Duel.IsChainSolving()
		and re and re:GetOwnerPlayer()==1-tp
end
-- 怪兽效果③的伤害处理（非连锁处理中），根据对方加入手牌的卡片数量，每张给予对方900点伤害。
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示此卡发动的动画提示。
	Duel.Hint(HINT_CARD,0,id)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	-- 给予对方“加入手牌卡片数量 × 900”的伤害。
	Duel.Damage(1-tp,ct*900,REASON_EFFECT)
end
-- 怪兽效果③的伤害标记触发条件（连锁处理中），检查此卡是否反转过，且对方在连锁处理中因自身卡的效果将卡加入手牌。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 检查加入手牌的卡是否属于对方，且当前正处于连锁处理中。
		and eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.IsChainSolving()
		and re and re:GetOwnerPlayer()==1-tp
end
-- 在连锁处理中，统计对方加入手牌的卡片数量，并在自身注册一个带有该数量作为Label的Flag标记，用于后续结算伤害。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(id+o,RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_CHAIN,0,1,ct)
end
-- 连锁处理完毕后的伤害结算条件，检查自身是否存在连锁中注册的伤害Flag标记。
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+o)>0
end
-- 连锁处理完毕后的伤害结算处理，累加所有Flag标记中记录的卡片数量，重置Flag并统一给予对方对应数值的伤害。
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示此卡发动的动画提示。
	Duel.Hint(HINT_CARD,0,id)
	local labels={e:GetHandler():GetFlagEffectLabel(id+o)}
	local ct=0
	for i=1,#labels do ct=ct+labels[i] end
	e:GetHandler():ResetFlagEffect(id+o)
	-- 给予对方“累计加入手牌卡片数量 × 900”的伤害。
	Duel.Damage(1-tp,ct*900,REASON_EFFECT)
end
