--雛神鳥シムルグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「斯摩夫」怪兽召唤。
-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
function c50820852.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「斯摩夫」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50820852,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,50820852)
	e1:SetTarget(c50820852.sumtg)
	e1:SetOperation(c50820852.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50820852,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,50820853)
	e2:SetCondition(c50820852.spcon)
	e2:SetTarget(c50820852.sptg)
	e2:SetOperation(c50820852.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：要求为发动者自己的回合，且自己可以进行通常召唤、存在追加通常召唤的次数，并且本回合尚未发动过同名①效果。
function c50820852.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否具备进行通常召唤的资格，且本回合存在追加通常召唤的次数（满足追加召唤的前提）。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 同时要求本回合还未使用过①效果（标志50820852为0），并且当前回合玩家是自己，保证只在自己回合发动。
		and Duel.GetFlagEffect(tp,50820852)==0 and Duel.GetTurnPlayer()==tp end
end
-- ①效果处理：若本回合尚未发动过①效果，则为己方玩家注册一个结束阶段重置的追加通常召唤效果，使手牌中的「斯摩夫」怪兽本回合可以在通常召唤外再召唤1次，并记录已发动的标志。
function c50820852.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认：若本回合已发动过①效果（标志非0），则直接终止处理，避免重复追加召唤次数。
	if Duel.GetFlagEffect(tp,50820852)~=0 then return end
	-- ①：这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「斯摩夫」怪兽召唤。②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(50820852,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设定追加通常召唤效果只对手牌中持有「斯摩夫」字段（0x12d）的怪兽适用。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x12d))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该追加通常召唤效果注册给当前玩家，使其在本回合生效。
	Duel.RegisterEffect(e1,tp)
	-- 为当前玩家注册一个回合内仅1次的已发动标志（代码50820852），并在结束阶段重置，用于限制同一回合不能重复发动①效果。
	Duel.RegisterFlagEffect(tp,50820852,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：判断卡片是否在对方的魔法与陷阱区域的5个后场格中（序列号0~4），场地魔法区不算在内。
function c50820852.cfilter(c)
	return c:GetSequence()<5
end
-- ②效果的发动条件判定：对方魔法与陷阱区域的5个后场中没有卡片存在。
function c50820852.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 不存在满足过滤条件的卡，即对方的魔法与陷阱区域（后场5格）空置时才允许发动。
	return not Duel.IsExistingMatchingCard(c50820852.cfilter,tp,0,LOCATION_SZONE,1,nil)
end
-- ②效果发动时检查：自己场上存在可用的怪兽区，且墓地的这张卡能够以表侧守备表示被特殊召唤；满足时才可发动。
function c50820852.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置本次效果处理的操作信息：将进行1只怪兽的特殊召唤，并指定对象为墓地中的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将这张卡以表侧守备表示特殊召唤，若成功则给它附加因该效果离场时除外的不无效效果；之后对发动者附加直到回合结束不能特殊召唤鸟兽族以外怪兽的效果。
function c50820852.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与②效果相关，并以表侧守备表示将其特殊召唤；如果特殊召唤成功则进入后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
	-- 这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c50820852.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该“不能特殊召唤鸟兽族以外怪兽”的自肃效果注册到发动者，使其在结束阶段前持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定函数：要特殊召唤的怪兽不是鸟兽族时，禁止特殊召唤。
function c50820852.splimit(e,c)
	return not c:IsRace(RACE_WINDBEAST)
end
