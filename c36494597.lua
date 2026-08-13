--テレポート・フュージョン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。自己的场上·墓地的念动力族怪兽作为融合素材除外，把1只念动力族融合怪兽融合召唤。
-- ②：从额外卡组特殊召唤的自己场上的表侧表示的念动力族怪兽被战斗·效果破坏的场合，把墓地的这张卡除外，以自己的除外状态的1只念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 为卡片注册两个效果：①效果是魔法卡发动，在主要阶段从自己场上·墓地除外念动力族素材进行融合召唤（1回合1次）；②效果是墓地诱发，当从额外卡组特殊召唤的表侧念动力族怪兽被战斗或效果破坏时，除外墓地中的这张卡并特殊召唤1只除外状态的念动力族怪兽（1回合1次）。
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。自己的场上·墓地的念动力族怪兽作为融合素材除外，把1只念动力族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：从额外卡组特殊召唤的自己场上的表侧表示的念动力族怪兽被战斗·效果破坏的场合，把墓地的这张卡除外，以自己的除外状态的1只念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 将墓地中的这张卡除外作为效果②发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件函数：仅允许在自己或对手的主要阶段发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否处于主要阶段。
	return Duel.IsMainPhase()
end
-- 筛选场上可作为融合素材的念动力族怪兽：场上存在、能被除外且不免疫当前效果。
function s.filter1(c,e)
	return c:IsRace(RACE_PSYCHO) and c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中可融合召唤的念动力族融合怪兽：满足种族与类型，能用给定素材组完成融合召唤，且能通过融合召唤特殊召唤。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PSYCHO) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选墓地中可作为融合素材的念动力族怪兽：满足种族、怪兽类型、可作为融合素材且能被除外。
function s.filter3(c)
	return c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 效果①的发动合法性检查：构建场上·墓地的融合素材组，确认额外卡组是否存在可融合召唤的念动力族融合怪兽；若通常素材不足则检查连锁素材；可行后设置从场上·墓地除外素材和从额外特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家场上可作为融合素材的念动力族怪兽集合（排除免疫效果的怪兽）。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 获取自己墓地中可作为融合素材的念动力族怪兽集合。
		local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在能用当前素材组融合召唤的念动力族融合怪兽，以决定能否发动。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家适用的连锁素材效果，用于扩展融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材，则使用其提供的素材组再次检查额外卡组是否存在可融合召唤的念动力族融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理时的除外操作信息：将从自己场上·墓地除外1张卡作为融合素材。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 设置效果处理时的特殊召唤操作信息：将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的处理：重新获取场上·墓地（墓地素材过滤王家长眠之谷影响）的融合素材，生成可融合召唤的额外怪兽列表；让玩家选择要融合召唤的怪兽；根据所选怪兽和素材来源执行普通融合或连锁素材融合；最后完成融合召唤处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取场上可作为融合素材的念动力族怪兽集合。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取墓地中可作为融合素材的念动力族怪兽，并排除因王家长眠之谷效果无法除外的卡。
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter3),tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 筛选额外卡组中能用普通素材组融合召唤的念动力族融合怪兽，作为可选特殊召唤对象。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组筛选额外卡组中可融合召唤的念动力族融合怪兽，得到另一组可选对象。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要融合召唤特殊召唤的怪兽卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是否属于普通融合素材可召唤的行列，且不是或不需要使用连锁素材；若涉及连锁素材则询问玩家是否使用，以决定走普通融合还是连锁素材分支。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通融合素材组中为当前选的融合怪兽选择一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat1==0 then goto cancel end
			tc:SetMaterial(mat1)
			-- 将选择的融合素材表侧除外，作为融合素材及效果消耗。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使除外素材与特殊召唤分开处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤的形式特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 当使用连锁素材时，从连锁素材提供的素材组中为当前选的融合怪兽选择一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			if #mat2==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②效果的怪兽判定条件：该怪兽是从额外卡组特殊召唤、在破坏前是我方场上表侧表示的念动力族怪兽，并且被战斗或效果破坏。
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:GetPreviousRaceOnField()&RACE_PSYCHO~=0 and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果②的触发条件：被破坏的怪兽中存在满足条件的念动力族怪兽，且不是墓地中的这张卡本身被破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 筛选除外状态中可作为特殊召唤对象的念动力族怪兽，要求表侧除外、种族为念动力且能够特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果②发动时的取对象处理：限制只能选择自己除外的念动力族怪兽，同时需要空位并存在合法对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) and chkc:IsControler(tp) end
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己除外状态中存在1只可特殊召唤的念动力族怪兽，可作为取对象目标。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己除外的念动力族怪兽中选择1只作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：将选择的对象卡进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：获取对象怪兽，若对象仍与连锁相关则将其特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象怪兽表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
