--宙の忍者－鳥帷
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡送去墓地才能发动。从手卡把1只「忍者」怪兽表侧守备表示或者里侧守备表示特殊召唤。
-- ②：这张卡在特殊召唤·反转的回合不会被战斗·效果破坏。
-- ③：对方的主要阶段以及战斗阶段才能发动。从自己的手卡·场上把「忍者」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
local s,id,o=GetID()
-- 注册该卡的全部效果：特殊召唤/反转成功时获得抗性（②），手牌起动特殊召唤（①），以及对方回合融合召唤（③）。
function s.initial_effect(c)
	-- ②：这张卡在特殊召唤·反转的回合不会被战斗·效果破坏。（对应“特殊召唤”时点）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
	-- ①：把这张卡从手卡送去墓地才能发动。从手卡把1只「忍者」怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：对方的主要阶段以及战斗阶段才能发动。从自己的手卡·场上把「忍者」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
-- 特殊召唤或反转成功时，给这张卡赋予直到回合结束/离场为止不会被战斗·效果破坏的抗性。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：这张卡在特殊召唤·反转的回合不会被战斗·效果破坏。（对应“不会被战斗破坏”抗性）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：把手卡中的这张卡送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地，作为效果的发动代价。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 筛选可作为①效果特殊召唤对象的卡：手卡中满足「忍者」字段且能够以守备表示特殊召唤的怪兽。
function s.filter(c,e,tp)
	return c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- ①效果的发动条件：自己场上有可用的怪兽区域，并且手卡中存在符合条件的「忍者」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只可特殊召唤的「忍者」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 设置操作信息，标明本效果将进行1次从手卡的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行①效果：选择1只手卡的「忍者」怪兽以守备表示特殊召唤；若为里侧守备表示则向对方确认。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若场上没有空位则效果处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 弹出提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只符合条件的「忍者」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以守备表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_DEFENSE)
		if g:GetFirst():IsFacedown() then
			-- 若特殊召唤的怪兽为里侧守备表示，则向对方玩家展示这张卡以确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ③效果的发动条件：仅在对方回合的主要阶段或战斗阶段可以发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为对方回合，并且阶段处于主要阶段1至主要阶段2之间（包含战斗阶段）。
	return Duel.GetTurnPlayer()~=tp and ph>=PHASE_MAIN1 and ph<=PHASE_MAIN2
end
-- 筛选额外牌组中可作为融合召唤对象的「忍者」融合怪兽，要求其为融合怪兽且能用给定素材进行融合召唤。
function s.sfilter(c,e,tp,m,f,chkf)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ③效果的合法对象检查：确认额外牌组存在能用自己手卡·场上的素材融合召唤的「忍者」融合怪兽；若通常素材不足，再检查连锁素材是否提供替代素材。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己可用的融合素材（手卡·场上的怪兽，以及额外融合素材效果提供的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外牌组中是否存在能用当前素材融合召唤的「忍者」融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取自己受到的连锁素材效果（若有），以便在通常素材不足时使用替代素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材提供的素材后，额外牌组中是否存在可融合召唤的「忍者」融合怪兽。
				res=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，标明本效果将进行1次从额外牌组的融合召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行③效果：选择额外牌组的1只「忍者」融合怪兽，选择融合素材送去墓地，进行融合召唤；若使用连锁素材则按其效果处理。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用融合素材，并排除不受当前效果影响的卡（这类卡不能作为融合素材）。
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 获取额外牌组中所有能用当前素材融合召唤的「忍者」融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果，用于扩展可选的融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取额外牌组中所有能用连锁素材提供的素材融合召唤的「忍者」融合怪兽。
		sg2=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出提示，让玩家选择要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选择的融合怪兽属于通常素材流程还是连锁素材流程：若该怪兽只能用通常素材召唤，或虽可用连锁素材但玩家选择不使用连锁素材，则走通常融合流程；否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从通常素材集合中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将所选融合素材送去墓地（作为融合素材，由效果送入墓地）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合召唤作为新的效果处理进行，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以表侧表示进行融合召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材提供的素材集合中选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
