--人造人間－サイコ・ジャッカー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「人造人-念力震慑者」使用。
-- ②：把这张卡解放才能发动。从卡组把「人造人-念力插孔者」以外的1只「人造人」怪兽加入手卡。那之后，对方的魔法与陷阱区域有盖放的卡的场合，那些全部确认。可以把最多有那之中的陷阱卡数量的「人造人」怪兽从手卡特殊召唤。
function c51916032.initial_effect(c)
	-- 注册卡名变更效果：使此卡在场上怪兽区或墓地期间，卡名视为「人造人-念力震慑者」（卡号77585513），对应①效果。
	aux.EnableChangeCode(c,77585513,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡解放才能发动。从卡组把「人造人-念力插孔者」以外的1只「人造人」怪兽加入手卡。那之后，对方的魔法与陷阱区域有盖放的卡的场合，那些全部确认。可以把最多有那之中的陷阱卡数量的「人造人」怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51916032,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,51916032)
	e2:SetCost(c51916032.cost)
	e2:SetTarget(c51916032.target)
	e2:SetOperation(c51916032.operation)
	c:RegisterEffect(e2)
end
-- 定义发动代价函数：先检查此卡能否解放；可解放时才允许发动，实际发动时将其解放作为代价。
function c51916032.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为发动效果的代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义检索过滤条件：必须是「人造人」系列怪兽、不是「人造人-念力插孔者」自身、是怪兽卡且能够加入手卡。
function c51916032.filter(c)
	return c:IsSetCard(0xbc) and not c:IsCode(51916032) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义效果发动目标函数：检查发动条件合法，并设置效果操作信息为从卡组检索加入手卡；实际检索在操作阶段进行。
function c51916032.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1只满足检索条件的「人造人」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c51916032.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本效果包含从卡组把1张卡加入手卡的分类，供连锁检测和效果发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义获取对方里侧表示魔陷的过滤条件：位于对方魔法与陷阱区域且为里侧表示，同时排除场地魔法格（序号<5）。
function c51916032.cffilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 定义特殊召唤过滤条件：手卡中的「人造人」怪兽，且能被当前效果以表侧表示特殊召唤。
function c51916032.spfilter(c,e,tp)
	return c:IsSetCard(0xbc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果处理流程：从卡组检索符合条件的「人造人」怪兽加入手卡并向对方展示；若对方魔陷区有里侧卡则确认，然后按其中陷阱卡的数量从手卡特殊召唤「人造人」怪兽。
function c51916032.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示选择提示，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足检索条件的「人造人」怪兽。
	local g=Duel.SelectMatchingCard(tp,c51916032.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若没有选到卡或加入手卡失败，则终止后续效果处理。
	if g:GetCount()==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	-- 向对方玩家展示本次检索加入手卡的卡片。
	Duel.ConfirmCards(1-tp,g)
	-- 检索后洗切手卡，保持手卡顺序随机。
	Duel.ShuffleHand(tp)
	-- 获取对方魔法与陷阱区域里侧表示且位于通常魔陷区的所有卡片。
	local cg=Duel.GetMatchingGroup(c51916032.cffilter,tp,0,LOCATION_SZONE,nil)
	if cg:GetCount()>0 then
		-- 中断当前效果，使后续特殊召唤处理与之前的检索确认处理视为不同时点，避免错过时点。
		Duel.BreakEffect()
		-- 让对方玩家确认那些里侧表示的卡片。
		Duel.ConfirmCards(tp,cg)
		-- 获取我方主要怪兽区可用的空格数量，用于限制特殊召唤的卡数。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		local ct=cg:FilterCount(Card.IsType,nil,TYPE_TRAP)
		if ct>ft then ct=ft end
		-- 获取手卡中可供特殊召唤的「人造人」怪兽列表。
		local sg=Duel.GetMatchingGroup(c51916032.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 当对方里侧陷阱数量大于0、手卡有可特殊召唤的「人造人」怪兽且当前玩家选择同意时，才执行特殊召唤。
		if ct>0 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(51916032,1)) then  --"是否特殊召唤「人造人」怪兽？"
			-- 提示当前玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,ct,nil)
			-- 将选择的「人造人」怪兽以表侧表示特殊召唤到当前玩家场上。
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
