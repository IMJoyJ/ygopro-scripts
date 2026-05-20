--解呪の神碑
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●对方在抽卡阶段以外从卡组把卡加入手卡的场合才能发动。对方手卡随机选1张丢弃。那之后，从对方卡组上面把2张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含两个可选的发动效果（丢弃手卡/除外卡组，以及从额外卡组特殊召唤神碑怪兽）。
function s.initial_effect(c)
	-- ●对方在抽卡阶段以外从卡组把卡加入手卡的场合才能发动。对方手卡随机选1张丢弃。那之后，从对方卡组上面把2张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡丢弃"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
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
-- 过滤对方从卡组加入手卡的卡的条件函数。
function s.ddfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 效果1的发动条件：当前不是抽卡阶段，且存在对方从卡组加入手卡的卡。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否不为抽卡阶段，且加入手卡的卡中是否存在对方从卡组加入手卡的卡。
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.ddfilter,1,nil,tp)
end
-- 效果1的发动目标检测与操作信息设置。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡数量是否大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 检查对方卡组最上方的2张卡是否都能被除外。
		and Duel.GetDecktopGroup(1-tp,2):FilterCount(Card.IsAbleToRemove,nil)==2 end
	-- 向对方玩家提示选择了发动该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置丢弃对方1张手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
	-- 设置从对方卡组除外2张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_DECK)
end
-- 效果1的效果处理：随机丢弃对方1张手卡，之后除外对方卡组最上方的2张卡，并跳过下次战斗阶段。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方的所有手卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(1-tp,1)
		-- 如果成功将随机选择的对方手卡因效果丢弃送去墓地。
		if Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)~=0 then
			-- 获取对方卡组最上方的2张卡。
			local g=Duel.GetDecktopGroup(1-tp,2)
			if #g>0 then
				-- 中断当前效果处理，使后续的除外处理与丢弃手卡不视为同时处理。
				Duel.BreakEffect()
				-- 禁用接下来的洗牌检测，防止因从卡组操作卡片而自动洗牌。
				Duel.DisableShuffleCheck()
				-- 将获取的对方卡组最上方的2张卡表侧表示除外。
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
	s.skipop(e,tp)
end
-- 过滤额外卡组中可以特殊召唤到额外怪兽区域的「神碑」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外怪兽区域是否有可用的特殊召唤空间。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 效果2的发动目标检测与操作信息设置。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足特殊召唤条件的「神碑」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方玩家提示选择了发动该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤额外卡组怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果2的效果处理：从额外卡组选择1只「神碑」怪兽在额外怪兽区域特殊召唤，并跳过下次战斗阶段。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「神碑」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽在额外怪兽区域表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 注册跳过下次自己战斗阶段的效果。
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前阶段。
		local ph=Duel.GetCurrentPhase()
		-- 这张卡的发动后，下次的自己战斗阶段跳过。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 判断当前是否为自己的回合，且处于战斗阶段中（即在主要阶段1之后、主要阶段2之前）。
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 将当前回合数记录在效果的Label中，用于后续判断是否在当前回合跳过。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 在全局注册跳过战斗阶段的玩家效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 跳过战斗阶段效果的生效条件函数。
function s.skipcon(e)
	-- 确保跳过战斗阶段的效果不在发动该卡片的当前回合立即生效（若在战斗阶段中发动，则跳过下一次的战斗阶段）。
	return Duel.GetTurnCount()~=e:GetLabel()
end
