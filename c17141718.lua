--花札衛－芒－
-- 效果：
-- ①：自己场上有7星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。手卡的「花札卫」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
function c17141718.initial_effect(c)
	-- ①：自己场上有7星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17141718.spcon)
	e1:SetTarget(c17141718.sptg)
	e1:SetOperation(c17141718.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。手卡的「花札卫」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c17141718.target)
	e2:SetOperation(c17141718.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义筛选条件：卡为表侧表示、属于「花札卫」系列且等级7以下，用于①的发动条件检查。
function c17141718.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsLevelBelow(7)
end
-- 效果①的发动条件：检查自己场上（主要怪兽区）是否存在满足cfilter的「花札卫」怪兽。
function c17141718.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 通过Duel.IsExistingMatchingCard检查自己场上（LOCATION_MZONE）是否存在至少1只表侧表示且7星以下的「花札卫」怪兽。
	return Duel.IsExistingMatchingCard(c17141718.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动合法性判定：确认自己主要怪兽区有空位，且这张卡能够被效果特殊召唤。
function c17141718.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区可用空格数大于0，保证特殊召唤有格子可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：声明本次连锁要特殊召唤这张卡（数量1），供其他效果（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将这张卡特殊召唤，并给自己附加『直到回合结束时不能召唤·特殊召唤非「花札卫」怪兽』的限制。
function c17141718.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区（需通过召唤条件和苏生限制的检查）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- ①：这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c17141718.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家tp注册“不能特殊召唤非「花札卫」怪兽”的限制效果，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 向玩家tp注册“不能通常召唤非「花札卫」怪兽”的限制效果，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
end
-- 限制判定：被检查的怪兽不是「花札卫」系列时，受到不能召唤/特殊召唤的限制。
function c17141718.splimit(e,c)
	return not c:IsSetCard(0xe6)
end
-- 定义效果②的手卡筛选条件：属于「花札卫」系列、能够回到卡组且未公开状态的卡。
function c17141718.filter(c)
	return c:IsSetCard(0xe6) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 效果②的发动条件判定：自己允许抽卡，且手卡中存在至少1张符合filter的「花札卫」怪兽。
function c17141718.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认玩家tp可以进行效果抽卡（不受“不能抽卡”效果影响）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 确认手卡中存在至少1张满足filter（「花札卫」、可回卡组、未公开）的卡，满足②的发动前提。
		and Duel.IsExistingMatchingCard(c17141718.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 将当前连锁的对象玩家设置为tp，使后续处理知道是tp进行回卡组和抽卡操作。
	Duel.SetTargetPlayer(tp)
	-- 登记操作信息：声明本效果会将玩家tp手卡中的卡（数量为1，实际可任意）返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理：选择任意数量的手卡「花札卫」怪兽给对方确认，送回卡组洗切，然后按返回数量抽卡，最后洗切手卡。
function c17141718.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家p（即tp），作为本次效果处理的玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 显示选择提示，让玩家p选择要返回卡组的卡片（提示文本为“请选择要返回卡组的卡”）。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家p从自身手卡中选择任意数量（1~99）满足filter的「花札卫」怪兽，作为返回卡组的对象。
	local g=Duel.SelectMatchingCard(p,c17141718.filter,p,LOCATION_HAND,0,1,99,nil)
	if g:GetCount()>0 then
		-- 将选中的手卡展示给对方玩家（1-p）确认，对应效果原文的『给对方观看』。
		Duel.ConfirmCards(1-p,g)
		-- 将选中的卡以效果原因送回其持有者的卡组（洗切后放回），并返回实际送回数量ct。
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切玩家p的卡组，确保回卡组后的卡组随机化。
		Duel.ShuffleDeck(p)
		-- 中断当前效果处理，使后续抽卡与回卡组过程视为不同时处理，避免错时点（对应“那之后”）。
		Duel.BreakEffect()
		-- 玩家p抽取与返回卡组数量ct相同张数的卡。
		Duel.Draw(p,ct,REASON_EFFECT)
		-- 洗切玩家p的手卡，以保证手卡顺序信息不被对手通过本次操作推断。
		Duel.ShuffleHand(p)
	end
end
