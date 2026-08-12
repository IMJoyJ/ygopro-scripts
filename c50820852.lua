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
-- 检查是否满足①效果的发动条件：玩家可以通常召唤、可以额外召唤、本回合未发动过此效果、且为当前回合玩家。
function c50820852.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以通常召唤。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查本回合是否已发动过此效果，以及是否为当前回合玩家。
		and Duel.GetFlagEffect(tp,50820852)==0 and Duel.GetTurnPlayer()==tp end
end
-- ①效果的处理函数：若未发动过此效果，则注册一个使玩家在本回合可额外召唤一次的字段效果，并记录该效果已发动。
function c50820852.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果本回合已发动过此效果则直接返回。
	if Duel.GetFlagEffect(tp,50820852)~=0 then return end
	-- 创建并注册一个影响场上所有玩家的字段效果，使玩家可以额外召唤一次，且目标为手牌区域的「斯摩夫」怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(50820852,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置该字段效果的目标为「斯摩夫」卡组中的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x12d))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该字段效果注册到游戏环境中。
	Duel.RegisterEffect(e1,tp)
	-- 记录本回合已发动过①效果，防止重复发动。
	Duel.RegisterFlagEffect(tp,50820852,RESET_PHASE+PHASE_END,0,1)
end
-- 用于判断对方魔法与陷阱区域是否有卡的过滤函数：检查指定位置的卡是否在魔法与陷阱区域（序列小于5）。
function c50820852.cfilter(c)
	return c:GetSequence()<5
end
-- ②效果的发动条件函数：检查对方魔法与陷阱区域是否没有卡。
function c50820852.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若对方魔法与陷阱区域不存在任何卡，则满足发动条件。
	return not Duel.IsExistingMatchingCard(c50820852.cfilter,tp,0,LOCATION_SZONE,1,nil)
end
-- ②效果的目标设定函数：检查是否有足够的怪兽区域进行特殊召唤，并判断该卡是否能以守备表示特殊召唤。
function c50820852.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁操作信息，指定本次效果将特殊召唤一张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数：若满足条件则特殊召唤该卡，并将其离场时除外；同时注册一个限制玩家不能特殊召唤非鸟兽族怪兽的效果。
function c50820852.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否能被特殊召唤，若可以则执行特殊召唤操作。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 创建并注册一个使该卡在离场时被除外的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
	-- 创建并注册一个限制玩家不能特殊召唤非鸟兽族怪兽的字段效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c50820852.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制特殊召唤的字段效果注册到游戏环境中。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤效果的目标过滤函数：若目标怪兽不是鸟兽族则不能特殊召唤。
function c50820852.splimit(e,c)
	return not c:IsRace(RACE_WINDBEAST)
end
