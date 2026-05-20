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
-- 注册卡片效果的初始化函数，包含灵摆属性、灵摆效果、手卡怪兽效果、诱发即时效果、反转标记效果、永续连锁限制效果以及特殊召唤限制计数器。
function s.initial_effect(c)
	-- 注册灵摆怪兽的基本属性（灵摆召唤和作为灵摆卡发动）。
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
	-- ③：只要反转过的这张卡在怪兽区域存在
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
	-- 注册一个自定义活动计数器，用于检测本回合玩家是否进行过非里侧守备表示的特殊召唤。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器的过滤函数，仅允许里侧表示的特殊召唤（若特殊召唤了表侧表示怪兽，则计数器增加）。
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 灵摆效果①的执行函数，给这张卡放置1个纠罪指示物。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤函数，检查是否是「纠罪巧」卡片。
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 灵摆效果②的发动条件判定函数，检查另一边的灵摆区域是否存在「纠罪巧」卡。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己另一边的灵摆区域是否存在「纠罪巧」卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤函数，筛选对方场上表侧表示且攻击力低于指定数值的怪兽。
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 灵摆效果②的靶向与发动检测函数，获取自身原本攻击力并选择对方场上1只符合条件的怪兽作为对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 效果发动时的可行性检测，检查对方场上是否存在可作为对象的、攻击力比此卡原本攻击力低的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只攻击力比此卡原本攻击力低的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置连锁信息，表明该效果的处理包含破坏选定卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果②的执行函数，破坏作为对象的怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的第一张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 因效果将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 怪兽效果①的Cost与发动条件判定函数，要求此卡未公开且本回合未进行过非里侧守备表示的特殊召唤，并注册本回合不能表侧特殊召唤的誓约限制。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合玩家是否尚未进行过非里侧守备表示的特殊召唤。
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。②：对方在连锁3以后把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。这个效果的发动时积累的连锁上的全部对方的效果的发动无效并破坏。③：只要反转过的这张卡在怪兽区域存在，对方不能对应自身的卡的效果的发动把卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册全局效果，限制玩家在本回合只能以里侧守备表示特殊召唤怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤表示形式的过滤函数，禁止表侧表示的特殊召唤。
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤函数，筛选手卡中可以里侧守备表示特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽效果①的靶向与发动检测函数，检查怪兽区域空位及手卡中是否存在可特殊召唤的怪兽，并设置特殊召唤的连锁信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受到「神圣之光」等禁止里侧守备表示特殊召唤的效果影响。
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己场上的怪兽区域是否有空位。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以里侧守备表示特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表明该效果的处理包含从手卡特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果①的执行函数，将手卡1只怪兽里侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只可以里侧守备表示特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切玩家的手卡。
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选定的怪兽以里侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若被特殊召唤的怪兽原本处于公开状态，则向对方玩家确认该卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤函数，筛选自己场上的卡片。
function s.ccfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
-- 怪兽效果②的发动条件判定函数，要求此卡在场上里侧表示存在，且对方在连锁3以后发动了卡的效果。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or rp~=1-tp then return false end
	if not c:IsFacedown() then return false end
	for i=1,ev do
		-- 获取指定连锁序号的发动玩家。
		local tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_PLAYER)
		-- 检查该连锁是否由对方发动，且该效果的发动是否可以被无效。
		if tgp~=tp and Duel.IsChainNegatable(i) then
			-- 判定当前连锁数是否在3以上。
			return Duel.GetCurrentChain()>2
		end
	end
	return false
end
-- 怪兽效果②的Cost函数，将里侧表示的此卡变成表侧守备表示。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将此卡改变为表侧守备表示。
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 怪兽效果②的靶向与发动检测函数，收集当前连锁中所有对方发动的、可被无效的效果，并设置无效与破坏的连锁信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取指定连锁序号的发动效果及发动玩家。
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		-- 检查该连锁是否由对方发动，且该效果的发动是否可以被无效。
		if tgp~=tp and Duel.IsChainNegatable(i) then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	-- 将需要破坏的卡片组设置为当前连锁的目标卡片。
	Duel.SetTargetCard(dg)
	-- 设置连锁信息，表明该效果的处理包含将指定数量的效果发动无效的操作。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,ng:GetCount(),0,0)
	-- 设置连锁信息，表明该效果的处理包含破坏指定数量卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 怪兽效果②的执行函数，将当前连锁中所有对方发动的效果无效并破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取指定连锁序号的发动效果及发动玩家。
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		-- 若该连锁由对方发动，则尝试将其发动无效。
		if tgp~=tp and Duel.NegateActivation(i) then
			local tc=te:GetHandler()
			if tc:IsRelateToEffect(e) and tc:IsRelateToChain(i) then
				dg:AddCard(tc)
			end
		end
	end
	-- 因效果将所有被无效发动的卡片破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
-- 反转时的辅助效果执行函数，给此卡注册“已反转过”的标记，并设置状态为已启用。
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已反转过"
	c:SetStatus(STATUS_EFFECT_ENABLED,true)
end
-- 怪兽效果③的连锁处理函数，若此卡已反转过且对方发动效果，则限制对方不能对应自身的卡的效果的发动来发动卡的效果。
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==1-tp and c:GetFlagEffect(id)>0 then
		-- 设定连锁限制，使得后续不能连锁发动不符合限制条件的效果。
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制的过滤函数，规定只有与当前发动效果的玩家相同的玩家才能进行连锁（即对方不能对应自身的卡的效果的发动把卡的效果发动）。
function s.chainlm(e,rp,tp)
	return tp==rp
end
