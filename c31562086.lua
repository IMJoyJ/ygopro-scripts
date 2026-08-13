--神碑の穂先
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●从卡组把「神碑的锋芒」以外的1张「神碑」卡加入手卡。那之后，从对方卡组上面把1张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 为神碑的锋芒注册两个效果：e1为检索+除外选项，e2为特殊召唤选项；两者都是魔法卡的发动效果，可在自由时点发动，并共用同名卡1回合1次的誓约次数限制（id+EFFECT_COUNT_CODE_OATH）。
function s.initial_effect(c)
	-- ●从卡组把「神碑的锋芒」以外的1张「神碑」卡加入手卡。那之后，从对方卡组上面把1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 检索用过滤函数：卡持有「神碑」字段、不是「神碑的锋芒」自身、并且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x17f) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 发动合法性检查：己方卡组存在符合条件的检索目标，且对方卡组最上方1张卡能够被除外。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组是否存在至少1张满足thfilter条件的「神碑」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查对方卡组最上方1张卡是否能够被除外（只有能被除外时才满足发动条件）。
		and Duel.GetDecktopGroup(1-tp,1):FilterCount(Card.IsAbleToRemove,nil)==1 end
	-- 向对方玩家提示己方选择发动的是哪个效果（显示对应的效果描述文字）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次效果处理中预计有1张卡从己方卡组加入手卡（用于检索类效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本次效果处理中预计有1张卡从对方卡组顶除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 检索选项的效果处理：从己方卡组选1张符合条件的「神碑」卡加入手卡并给对方确认、洗切卡组；随后从对方卡组顶除外1张（用BreakEffect使除外作为不同时处理）；最后执行跳过战斗阶段。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组选择1张满足thfilter条件的「神碑」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若选择了卡且成功加入手卡（返回实际操作数>0），才继续执行后续除外处理。
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 检索后洗切己方卡组。
		Duel.ShuffleDeck(tp)
		-- 取对方卡组最上方1张卡，作为准备除外的对象。
		local g1=Duel.GetDecktopGroup(1-tp,1)
		if #g1>0 then
			-- 中断当前效果处理，使后续的除外效果视为另一次处理，避免与检索效果错时点联动。
			Duel.BreakEffect()
			-- 禁用紧接着的自动洗切检查，因为这是从卡组顶端除外，不应触发卡组洗切。
			Duel.DisableShuffleCheck()
			-- 将对方卡组最上方1张卡以表侧表示除外。
			Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
		end
	end
	s.skipop(e,tp)
end
-- 特殊召唤用过滤函数：额外卡组的「神碑」怪兽能够被特殊召唤，且己方额外怪兽区域有可用空格。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查己方额外怪兽区域是否存在可用空格（zone=0x60），确保特殊召唤到额外怪兽区域。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 特殊召唤选项的发动合法性检查：额外卡组存在满足spfilter的「神碑」怪兽；并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只可特殊召唤且额外怪兽区域有空位的「神碑」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方玩家提示己方选择发动的是特殊召唤效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次效果处理中预计有1只怪兽从额外卡组特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤选项的效果处理：从额外卡组选1只符合条件的「神碑」怪兽特殊召唤到额外怪兽区域；随后执行跳过战斗阶段。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示文字，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足spfilter条件的「神碑」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到额外怪兽区域（zone=0x60）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 跳过战斗阶段效果的通用处理：给己方玩家施加“跳过下次自己的战斗阶段”的永续效果；若发动时已处于本回合主要阶段1之后、主要阶段2之前，则通过label和condition将跳过延后到下一回合。
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前阶段，用于判断本回合是否已经过了主要阶段1。
		local ph=Duel.GetCurrentPhase()
		-- 这张卡的发动后，下次的自己战斗阶段跳过。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 判断当前是否为己方回合的主要阶段1之后、主要阶段2之前（即即将进入本回合战斗阶段），若是则需要将跳过时机延后到下次自己的战斗阶段。
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 将当前回合数记录到效果label中，作为延迟跳过的判断依据。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 将“跳过战斗阶段”的效果注册给己方玩家，并按设定时机重置。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 跳过战斗阶段的触发条件：当前回合数不等于记录label时，说明不是发动的那一回合，从而实现“下次”战斗阶段跳过。
function s.skipcon(e)
	-- 返回当前回合数是否不等于label；若不等于则跳过战斗阶段效果生效。
	return Duel.GetTurnCount()~=e:GetLabel()
end
