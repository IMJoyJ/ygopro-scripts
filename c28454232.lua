--糾罪巧－Astaγ.PIXIEA
-- 效果：
-- ←0 【灵摆】 0→
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：自己场上的卡为对象的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。那个效果无效。那之后，可以把对方手卡随机1张里侧除外。
-- ③：只要反转过的这张卡在怪兽区域存在，对方不能把场上·墓地的卡作为效果的对象。
local s,id,o=GetID()
-- 初始化效果：为这张卡添加灵摆属性并允许在灵摆区域放置纠罪指示物，注册灵摆效果①（每次怪兽反转放置指示物）、灵摆效果②（战斗阶段结束时破坏攻击力较低的对方怪兽）、怪兽效果①（从手卡里侧守备特殊召唤）、怪兽效果②（无效对方以我方的卡为对象的效果并可除外对方手卡）、反转标记效果及怪兽效果③（保护场上·墓地的卡不被取为对象），并设置特殊召唤计数器
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡在灵摆区域发动
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
	-- ①：把手卡的这张卡给对方观看才能发动。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：自己场上的卡为对象的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。那个效果无效。那之后，可以把对方手卡随机1张里侧除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"除外"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- 只要反转过的这张卡在怪兽区域存在（注册反转时触发的不入连锁效果，用于记录这张卡已经反转过）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- ③：只要反转过的这张卡在怪兽区域存在，对方不能把场上·墓地的卡作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IMMEDIATELY_APPLY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE)
	e5:SetCondition(s.effcon)
	-- 设定该保护效果只影响对方玩家：双方场上·墓地的卡都不会成为对方发动的效果的对象
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
	-- 注册特殊召唤操作计数器：本回合进行过非里侧表示特殊召唤的玩家将不能再发动怪兽效果①
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤函数：里侧表示的卡进行的特殊召唤不计入限制（里侧守备表示特殊召唤不受限制）
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 每次有怪兽反转时，给灵摆区域的这张卡放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤函数：这张卡是「纠罪巧」卡（卡组系列字段为0x1d4）
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 发动条件：另一边的自己的灵摆区域有这张卡以外的「纠罪巧」卡存在
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在这张卡以外的1张以上「纠罪巧」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 破坏对象过滤函数：表侧表示且攻击力低于这张卡攻击力的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 取对象目标函数：获取这张卡的原本攻击力，确认选择链中的对象是对方怪兽区域攻击力较低的怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 发动时点检查：对方怪兽区域是否存在可以成为对象的、攻击力比这张卡低的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方怪兽区域1只攻击力低于这张卡的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置操作信息：本连锁确定要破坏对象中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得连锁的对象怪兽，若其仍与连锁相关且为怪兽，则以效果破坏它
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（要破坏的那只怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将对象怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 发动代价检查：这张卡尚未给对方观看（手卡中非公开状态），且本回合尚未进行过非里侧表示的特殊召唤
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合自己特殊召唤计数为0，即尚未进行过非里侧守备表示的特殊召唤（否则不能发动此效果）
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- （这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将特殊召唤表示形式限制效果注册为玩家效果，本回合内对自己生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤函数：表侧表示的特殊召唤被禁止，即本回合自己不用里侧守备表示不能把怪兽特殊召唤
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 特殊召唤候选过滤函数：这张卡可以里侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 目标函数：若玩家受「神光」效果影响（不能里侧特殊召唤）则不能发动；否则检查自己怪兽区域有空位且手卡有可以里侧守备表示特殊召唤的怪兽，并设置从手卡特殊召唤1只的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受到「神圣光辉」效果影响（该效果下怪兽不能盖放，无法里侧守备表示特殊召唤）
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己怪兽区域是否有可用的空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡是否存在可以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁预计从手卡特殊召唤1只怪兽（具体卡片在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：怪兽区域无空位则中止；提示并从手卡选择1只可里侧守备特殊召唤的怪兽，洗切手卡后将那里侧守备表示特殊召唤，若该怪兽是公开的（如被展示过）则给对方确认
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己怪兽区域没有空位则中止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从手卡选择1只可以里侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切自己的手卡，防止对方得知所选卡的位置
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选择的怪兽里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若特殊召唤的怪兽原本处于公开状态，则给对方确认那张卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 对象过滤函数：这张卡在自己场上（为自己控制的场上的卡）
function s.ccfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
-- 发动条件：这张卡未被战斗破坏、对方发动的效果以卡为对象、该连锁可以被无效、对象中包含自己场上的卡、发动者为对方、且这张卡为里侧表示
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得该连锁效果的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 综合判断：该连锁可以被无效，且其对象中存在自己场上的卡，发动者为对方，这张卡为里侧表示
	return Duel.IsChainDisablable(ev) and tg and tg:IsExists(s.ccfilter,1,nil,tp) and ep~=tp and e:GetHandler():IsFacedown()
end
-- 发动代价：无条件可支付，处理时把里侧表示的这张卡变成表侧守备表示
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把里侧表示的这张卡变成表侧守备表示（发动代价）
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 目标函数：设置操作信息，本连锁将使对方的1个效果无效
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本连锁确定要无效对方发动的那1个效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理：无效对方那个效果；若成功无效且对方手卡有可以里侧除外的卡，询问是否除外；是则中断时点，从对方手卡随机选1张里侧除外
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方发动的那个连锁效果无效
	if Duel.NegateEffect(ev)
		-- 检查对方手卡是否存在可以里侧表示除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,POS_FACEDOWN)
		-- 询问自己玩家是否执行除外（对应「可以把对方手卡随机1张里侧除外」）
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否除外？"
		-- 中断当前效果处理，使之后的除外处理与无效处理视为不同时进行
		Duel.BreakEffect()
		-- 取得对方手卡中所有可以里侧表示除外的卡
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,POS_FACEDOWN)
		if g:GetCount()>0 then
			local sg=g:RandomSelect(tp,1)
			-- 将随机选出的对方手卡1张以里侧表示除外
			Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
-- 这张卡反转时注册标志效果，记录这张卡已经反转过，并显示客户端提示「已反转过」
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"已反转过"
end
-- 永续效果适用条件：这张卡持有「已反转过」标志，即反转过的这张卡在怪兽区域存在
function s.effcon(e)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)>0
end
