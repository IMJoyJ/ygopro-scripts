--黄金の雫の神碑
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●对方从卡组抽1张。那之后，从对方卡组上面把4张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 注册两张魔法效果的e1、e2，分别对应①的两个可选效果；两者都作为速攻魔法可在自由时点发动，并通过相同code的EFFECT_COUNT_CODE_OATH限制共用1回合1次的发动次数。
function s.initial_effect(c)
	-- ●对方从卡组抽1张。那之后，从对方卡组上面把4张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方抽卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
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
-- 发动合法性检查：需要对方能抽1张、对方卡组至少剩5张，且卡组最上方4张都能被除外。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方可以抽1张卡，且对方卡组总数不少于5（抽1张+除外4张所需）。
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=5
		-- 检查对方卡组最上方4张卡是否全部都能被除外，若存在不能除外的卡则不能发动。
		and Duel.GetDecktopGroup(1-tp,4):FilterCount(Card.IsAbleToRemove,nil)==4 end
	-- 向对方玩家提示：我方选择了“对方抽卡”效果，并显示该效果的描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本连锁包含抽卡效果，将使对方抽取1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	-- 设置操作信息：本连锁包含除外效果，将把对方卡组最上方的4张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,4,1-tp,LOCATION_DECK)
end
-- 效果处理：让对方抽1张卡；若抽卡成功，则取对方卡组最上方4张卡，先BreakEffect错开时点，再禁止自动洗牌并以表侧表示除外；最后调用s.skipop设置跳过自己的下一次战斗阶段。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方以效果原因抽1张卡；只有实际抽卡成功（返回值非0）才执行后续的除外处理。
	if Duel.Draw(1-tp,1,REASON_EFFECT)~=0 then
		-- 取得对方卡组最上方的4张卡，作为接下来要除外的对象。
		local g=Duel.GetDecktopGroup(1-tp,4)
		if #g>0 then
			-- 中断当前效果链，使抽卡和之后的除外在不同时点处理，避免错过触发时点。
			Duel.BreakEffect()
			-- 禁用本次操作后的自动洗牌检测，因为是从卡组顶端除外，不应当洗切卡组。
			Duel.DisableShuffleCheck()
			-- 将取得的4张卡以表侧表示除外，原因为效果（REASON_EFFECT）。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	s.skipop(e,tp)
end
-- 定义特殊召唤候选卡的筛选条件：卡名属于「神碑」字段、能够被特殊召唤，且自己的额外怪兽区域有空位。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外要求：特殊召唤到额外怪兽区域（0x60）时，该区域必须存在可用空格。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 特殊召唤效果的发动条件与发动时的提示：检查额外卡组存在符合条件的「神碑」怪兽；满足后向对方告知选择“特殊召唤”效果，并设置操作信息为特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的额外卡组中是否存在至少1只满足s.spfilter条件的「神碑」怪兽，以此作为可发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方玩家提示：我方选择了“特殊召唤”效果，并显示该效果的描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本连锁包含特殊召唤效果，将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果的处理：让玩家从额外卡组选择1只符合条件的「神碑」怪兽，并将其特殊召唤到额外怪兽区域；最后调用s.skipop设置跳过自己的下一次战斗阶段。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的额外卡组中选出1只满足s.spfilter条件的「神碑」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到额外怪兽区域（0x60）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 公共函数s.skipop：为这张卡的发动添加“跳过自己的下一次战斗阶段”的誓约效果；根据发动时是否处于战斗阶段来决定效果的持续回合数，并注册给玩家。
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前所处阶段，用于判断效果是在战斗阶段内发动，从而决定跳过战斗阶段的时机。
		local ph=Duel.GetCurrentPhase()
		-- 这张卡的发动后，下次的自己战斗阶段跳过。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 若当前是自己回合且正处于战斗阶段（PHASE_MAIN1之后、PHASE_MAIN2之前），说明本回合战斗阶段已经到来/开始，需将“下次战斗阶段”延迟到下一回合。
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 将当前回合数记录到效果的label中，供skipcon判断当前是否已经过了发动回合。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 将跳过战斗阶段的效果注册给玩家tp，使该效果在其后续回合持续起作用。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义skipcon条件：仅在当前回合数与记录的不同时，才允许跳过战斗阶段，从而实现延迟到下一回合。
function s.skipcon(e)
	-- 返回当前回合数是否不等于label记录的回合数；若不等则效果生效，跳过当回合的战斗阶段。
	return Duel.GetTurnCount()~=e:GetLabel()
end
