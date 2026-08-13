--光の天穿バハルティヤ
-- 效果：
-- 这张卡可以把1只效果怪兽解放作上级召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡在手卡存在，对方主要阶段对方用抽卡以外的方法从卡组把卡加入手卡的场合才能发动。这张卡上级召唤。
-- ②：这张卡从手卡的召唤·特殊召唤成功的场合才能发动。对方把自身手卡数量的卡从卡组上面里侧表示除外。那之后，对方让手卡全部回到卡组，这个效果除外的卡加入手卡。
function c53318263.initial_effect(c)
	-- 这张卡可以把1只效果怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53318263,0))  --"把1只效果怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c53318263.rlcon)
	e1:SetOperation(c53318263.rlop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡在手卡存在，对方主要阶段对方用抽卡以外的方法从卡组把卡加入手卡的场合才能发动。这张卡上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53318263,1))
	e3:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c53318263.sumcon)
	e3:SetTarget(c53318263.sumtg)
	e3:SetOperation(c53318263.sumop)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从手卡的召唤·特殊召唤成功的场合才能发动。对方把自身手卡数量的卡从卡组上面里侧表示除外。那之后，对方让手卡全部回到卡组，这个效果除外的卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53318263,2))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,53318263)
	e4:SetTarget(c53318263.thtg)
	e4:SetOperation(c53318263.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c53318263.thcon)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断怪兽是否为效果怪兽，用于筛选可解放的效果怪兽。
function c53318263.rlfilter(c)
	return c:IsType(TYPE_EFFECT)
end
-- 上级召唤规则效果的发动条件：此卡为6星以上、需要解放数不超过1，且场上存在可解放的效果怪兽时，允许进行上级召唤。
function c53318263.rlcon(e,c,minc)
	if c==nil then return true end
	-- 获取双方场上所有效果怪兽的集合，作为上级召唤的可选解放素材。
	local mg=Duel.GetMatchingGroup(c53318263.rlfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判定此卡等级不低于6、解放数量要求为1，并且场上存在足够的解放素材（效果怪兽）。
	return c:IsLevelAbove(6) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤的处理过程：从场上选择1只效果怪兽作为解放素材，将其解放后完成上级召唤。
function c53318263.rlop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上所有效果怪兽的集合，供选择解放素材使用。
	local mg=Duel.GetMatchingGroup(c53318263.rlfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让玩家从集合中选择1只效果怪兽作为上级召唤的解放素材。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的解放素材以‘上级召唤的素材解放’原因解放。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数：判断卡是否为对方控制的、从卡组加入手卡且不是通过抽卡方式加入的卡。
function c53318263.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
-- ①效果的发动条件：当前为对方主要阶段，且对方有非抽卡方式从卡组加入手卡的卡，此时此卡在手卡可发动。
function c53318263.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否在主要阶段。
	local ph=Duel.GetCurrentPhase()
	-- 综合判定：当前是对方回合的主要阶段、对方有非抽卡从卡组加入手卡的行为，满足①效果的发动条件。
	return Duel.GetTurnPlayer()==1-tp and eg:IsExists(c53318263.cfilter,1,nil,1-tp) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- ①效果的发动合法检查：若此卡能进行上级召唤或覆盖召唤则允许发动，并设置后续召唤的操作信息。
function c53318263.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1) end
	-- 设置操作信息，标记本次连锁包含‘召唤/覆盖召唤’，供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
-- ①效果的处理：根据玩家选择的表示形式，将此卡从手卡进行上级召唤或里侧覆盖召唤。
function c53318263.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local pos=0
	if c:IsSummonable(true,nil,1) then pos=pos+POS_FACEUP_ATTACK end
	if c:IsMSetable(true,nil,1) then pos=pos+POS_FACEDOWN_DEFENSE end
	if pos==0 then return end
	-- 让玩家选择召唤的表示形式；若选择表侧攻击表示，则后续执行表侧上级召唤，否则执行里侧覆盖。
	if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
		-- 无视一回合通常召唤次数限制，以至少1只解放素材将此卡从手卡表侧攻击表示通常召唤（上级召唤）。
		Duel.Summon(tp,c,true,nil,1)
	else
		-- 无视一回合通常召唤次数限制，以至少1只解放素材将此卡从手卡里侧守备表示通常召唤（覆盖）。
		Duel.MSet(tp,c,true,nil,1)
	end
end
-- ②效果在特殊召唤成功时的追加条件：此卡必须是从手卡发动的特殊召唤，即‘从手卡的特殊召唤成功的场合’。
function c53318263.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- ②效果的发动检查：根据对方手卡数量确定从对方卡组顶里侧除外的张数，并确认这些卡可以除外、对方手卡可以全部返回卡组。
function c53318263.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得对方手卡的所有卡，用于计算数量以及后续送回卡组。
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local ct=#hg
	-- 取得对方卡组最上方等于对方手卡数量的卡，作为将要里侧除外的对象。
	local dg=Duel.GetDecktopGroup(1-tp,ct)
	if chk==0 then return ct>0 and dg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==ct
		and hg:FilterCount(Card.IsAbleToDeck,nil)==ct end
	-- 将本连锁处理的对象玩家设置为对方，后续操作信息以此为准。
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息：将从对方卡组顶除外ct张卡，位置为卡组，分类为除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,ct,1-tp,LOCATION_DECK)
	-- 设置操作信息：将对方手卡ct张卡返回卡组，分类为回到卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,hg,ct,0,0)
end
-- ②效果处理：将对方卡组顶对方手卡数量的卡里侧除外；之后将对方手卡全部洗回卡组，再将除外的卡加入对方手卡。
function c53318263.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象玩家（对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 取得对方当前的手卡（以处理时的实际手卡为准）。
	local hg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	local ct=#hg
	-- 取得对方卡组顶等于当前手卡数量的卡，作为除外对象。
	local dg=Duel.GetDecktopGroup(p,ct)
	-- 若对方手卡数大于0，且卡组顶对应数量的卡均能里侧除外，则执行里侧除外；实际除外数量必须等于手卡数才继续后续。
	if ct>0 and dg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==ct and Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)==ct then
		-- 中断当前效果处理，使后续操作视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 取得上一次卡片操作中被实际操作的卡组，即刚被里侧除外的卡。
		local og=Duel.GetOperatedGroup()
		-- 将对方手卡全部洗回持有者卡组并洗切；若返回卡组的卡数大于0，则继续执行后续。
		if Duel.SendtoDeck(hg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			-- 将之前里侧除外的卡加入对方手卡。
			Duel.SendtoHand(og,p,REASON_EFFECT)
		end
	end
end
