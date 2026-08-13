--プランキッズ・ウェザー
-- 效果：
-- 「调皮宝贝」怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的「调皮宝贝」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：对方回合把这张卡解放，以融合怪兽以外的自己墓地2只「调皮宝贝」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗破坏。
function c44509529.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以2只满足「调皮宝贝」系列条件的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x120),2,true)
	-- ①：自己的「调皮宝贝」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(c44509529.actcon)
	c:RegisterEffect(e1)
	-- ②：对方回合把这张卡解放，以融合怪兽以外的自己墓地2只「调皮宝贝」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44509529,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,44509529)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
	e2:SetCondition(c44509529.spcon)
	e2:SetCost(c44509529.spcost)
	e2:SetTarget(c44509529.sptg)
	e2:SetOperation(c44509529.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：存在自己的「调皮宝贝」怪兽正在攻击（攻击怪兽的控制者为这张卡的控制者，且属于「调皮宝贝」系列）。
function c44509529.actcon(e)
	-- 获取当前正在攻击的怪兽。
	local a=Duel.GetAttacker()
	return a and a:IsControler(e:GetHandlerPlayer()) and a:IsSetCard(0x120)
end
-- ②效果的发动条件：仅在对方回合才能发动（当前回合玩家不是这张卡的控制者）。
function c44509529.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是本卡控制者，即满足“对方回合”。
	return Duel.GetTurnPlayer()~=tp
end
-- 筛选可作为解放或代替解放除外的代价候选：该卡为表侧表示或在墓地，可作为代价除外，且持有25725326号效果（允许代替解放）。
function c44509529.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 判断选择该卡作为解放/代替解放后，自己场上仍至少有2个可用怪兽区，且墓地可选特殊召唤的「调皮宝贝」怪兽中卡名种类不少于2，以满足同名卡最多1张的限制。
function c44509529.costfilter(c,tp,g)
	local tg=g:Clone()
	tg:RemoveCard(c)
	-- 剩余可用怪兽区数量>1，且候选特殊召唤的怪兽中不同卡名数量>=2。
	return Duel.GetMZoneCount(tp,c)>1 and tg:GetClassCount(Card.GetCode)>=2
end
-- 支付代价：从所有可用代价卡中筛选出符合条件的1张（优先自动选择，若多张则手动选择）；若该卡持有25725326代替解放效果，则除外作为代替解放并消耗次数，否则直接解放。
function c44509529.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	-- 取得自己场上或墓地中所有可作为解放/代替解放代价的候选卡（包括持有25725326效果的卡）。
	local g=Duel.GetMatchingGroup(c44509529.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 取得自己墓地中所有可被本效果特殊召唤的「调皮宝贝」怪兽候选组（融合怪兽以外且满足召唤条件）。
	local tg=Duel.GetMatchingGroup(c44509529.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then
		e:SetLabel(100)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133) and g:IsExists(c44509529.costfilter,1,nil,tp,tg)
	end
	local cg=g:Filter(c44509529.costfilter,nil,tp,tg)
	local tc
	if #cg>1 then
		-- 当存在多张可选的解放/代替解放代价卡时，向玩家显示“请选择要解放或代替解放除外的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=cg:Select(tp,1,1,nil):GetFirst()
	else
		tc=cg:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将选择的代价卡表侧表示除外，作为代替解放（REASON_COST+REASON_REPLACE）。
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将选择的代价卡解放，作为发动代价（REASON_COST）。
		Duel.Release(tc,REASON_COST)
	end
end
-- 特殊召唤对象的过滤条件：是「调皮宝贝」系列、不是融合怪兽、能成为效果对象且能被特殊召唤。
function c44509529.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and not c:IsType(TYPE_FUSION)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的选择对象处理：从墓地候选组中选择2张卡名不同的「调皮宝贝」怪兽作为对象，并设定特殊召唤的操作信息。
function c44509529.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetLabel()==100 end
	e:SetLabel(0)
	-- 获取墓地中符合条件的「调皮宝贝」怪兽候选组。
	local g=Duel.GetMatchingGroup(c44509529.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从候选组中选择恰好2张卡，且要求所选卡卡名互不相同（同名卡最多1张）。
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选择的2张卡登记为本效果的对象（取对象）。
	Duel.SetTargetCard(g1)
	-- 设置操作信息：本效果将把g1中的2只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果处理：检查对象和可用怪兽区；若青眼精灵龙效果适用且要特招2只则不能处理；位置不足时选择可特招的数量；逐只特殊召唤，并给召唤成功的怪兽赋予本回合战斗破坏抗性。
function c44509529.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前可用的主要怪兽区数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 取得本连锁中登记的对象卡组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or ft<=0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<g:GetCount() then
		-- 当可用位置少于对象数量时，提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 对每只对象怪兽尝试特殊召唤；若成功，则为该怪兽附加战斗破坏抗性效果。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽在这个回合不会被战斗破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
	-- 结束多只怪兽的特殊召唤处理，完成特殊召唤。
	Duel.SpecialSummonComplete()
end
