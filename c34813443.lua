--果てなき灰滅
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。包含「灭亡龙 威多释」的自己·对方场上的怪兽作为融合素材，把1只炎族融合怪兽融合召唤。这个效果特殊召唤的怪兽的攻击力上升那些作为融合素材的怪兽数量×500。
-- ②：从自己墓地把1只炎族·暗属性怪兽和这张卡除外才能发动。对方场上的全部怪兽直到回合结束时变成炎族。
local s,id,o=GetID()
-- 初始化效果注册：e1为魔陷发动许可，e2注册①的融合召唤效果（主要阶段/二速/1回合1次），e3注册②的墓地除外变种族效果（二速/1回合1次）。
function s.initial_effect(c)
	-- 记录此卡效果文本中记载的「灭亡龙 威多释」卡号（78783557），用于卡名关联与素材要求判断。
	aux.AddCodeList(c,78783557)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段才能发动。包含「灭亡龙 威多释」的自己·对方场上的怪兽作为融合素材，把1只炎族融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.fscon)
	e2:SetTarget(s.fstg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
	-- ②：从自己墓地把1只炎族·暗属性怪兽和这张卡除外才能发动。对方场上的全部怪兽直到回合结束时变成炎族。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"改变种族"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.attcost)
	e3:SetTarget(s.atttg)
	e3:SetOperation(s.attop)
	c:RegisterEffect(e3)
end
s.fusion_effect=true
-- ①效果的发动条件函数：判定当前阶段是否为主要阶段1或主要阶段2，满足“自己·对方的主要阶段才能发动”。
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，若是则条件成立。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 筛选可作为融合素材的表侧表示怪兽，用于收集对方场上可作为素材的怪兽。
function s.filter0(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
-- 筛选可作为融合素材且不免疫当前效果的表侧怪兽，用于实际选择素材时排除不受效果影响者。
function s.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中符合条件的融合召唤对象：炎族融合怪兽、可被本效果以融合召唤方式特殊召唤，且能与指定素材组满足融合素材条件（含附加素材限制）。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PYRO) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选仍在场上且不免疫当前效果的怪兽，用于取得己方场上可用的融合素材。
function s.filter3(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 附加融合素材检查：素材组中必须至少存在1张卡名为「灭亡龙 威多释」的怪兽（卡号78783557）。
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionCode,1,nil,78783557)
end
-- ①效果的发动阶段处理：检查能否用双方场上素材（含「灭亡龙 威多释」）融合召唤炎族融合怪兽；若可行则向对方提示发动、登记本回合①效果已使用，并设置特殊召唤的操作信息。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得玩家tp可用的融合素材组，并仅保留场上的卡，以符合“场上的怪兽作为融合素材”的要求。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 取得对方场上表侧表示且可作为融合素材的怪兽，作为对方侧素材候选。
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 设置附加融合素材检查：本次融合素材必须包含「灭亡龙 威多释」。
		aux.FCheckAdditional=s.fcheck
		-- 检查额外卡组中是否存在可用mg1作为素材、满足s.filter2条件的炎族融合怪兽，以判断能否发动①效果。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家tp的连锁素材效果（代替融合素材的效果），以备在通常素材不足时使用。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 改用连锁素材效果提供的素材mg3和素材限制mf，再次检查额外卡组是否存在可融合召唤的炎族融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 清除之前设置的附加融合素材检查，恢复默认融合素材条件。
		aux.FCheckAdditional=nil
		-- ①效果发动判定：本回合尚未使用过①效果（flag为0），且存在可融合召唤的目标，则返回真。
		return Duel.GetFlagEffect(tp,id+o)==0 and res
	end
	-- 发动时向对方玩家提示正在发动的效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 为玩家tp注册本回合已使用过①效果的标识，回合结束重置，以实现1回合1次。
	Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：本效果将把额外卡组的1只怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：选择1只炎族融合怪兽，用包含「灭亡龙 威多释」的双方场上怪兽作为融合素材融合召唤；特殊召唤成功后使该怪兽攻击力上升素材数量×500。若存在连锁素材效果，则按其规则执行。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 处理融合时取得玩家tp当前场上且不免疫此效果的融合素材，作为通常素材候选。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter3,nil,e)
	-- 处理融合时取得对方场上表侧且不免疫此效果的怪兽，作为对方侧素材候选。
	local mg2=Duel.GetMatchingGroup(s.filter1,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 再次设置附加融合素材检查：素材必须包含「灭亡龙 威多释」。
	aux.FCheckAdditional=s.fcheck
	-- 使用通常素材mg1检索额外卡组中可融合召唤的炎族融合怪兽，得到候选组sg1。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家tp的连锁素材效果，用于支持代替素材的融合。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材效果提供的素材mg3（含限制mf）检索额外卡组中的炎族融合怪兽，得到候选组sg2。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽（显示“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽是否走通常融合流程：若在通常素材候选sg1中且（没有连锁素材候选或用不用连锁素材由玩家决定）则用通常素材；否则用连锁素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常素材mg1中为所选融合怪兽选择一组满足条件的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地（原因：效果+素材+融合召唤）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使素材送墓与之后的特殊召唤视为不同时点，避免错过时点。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式表侧表示特殊召唤到玩家tp场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果时，从代替素材mg3中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		-- 这个效果特殊召唤的怪兽的攻击力上升那些作为融合素材的怪兽数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetMaterialCount()*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:CompleteProcedure()
	end
	-- 清除之前设置的附加融合素材检查，恢复默认融合素材条件。
	aux.FCheckAdditional=nil
end
-- ②效果的COST过滤器：筛选墓地中的炎族·暗属性怪兽，且可作为COST除外。
function s.costfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动条件过滤器：对方场上有表侧表示且种族不是炎族的怪兽时才可发动。
function s.crfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_PYRO)
end
-- ②效果的COST处理：从墓地选择1只炎族·暗属性怪兽，连同这张卡自身一起以表侧表示除外。
function s.attcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查COST是否满足：墓地存在1只符合条件的炎族·暗属性怪兽，且这张卡自身能够除外。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) and c:IsAbleToRemoveAsCost() end
	-- 提示玩家选择要除外的卡（显示“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择1张满足costfilter的炎族·暗属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选择的墓地怪兽和这张卡自身以表侧表示除外，作为COST。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的发动目标检查：对方场上有表侧表示且非炎族的怪兽时才能发动。
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动检查阶段，检查对方场上是否存在至少1只表侧且非炎族的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.crfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 执行②效果：对方场上的全部表侧怪兽直到回合结束时变成炎族。
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的全部表侧表示怪兽，准备对其附加种族变更效果。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历对方场上的每只表侧怪兽，逐一附加种族变更效果。
	for tc in aux.Next(g) do
		-- 对方场上的全部怪兽直到回合结束时变成炎族。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_PYRO)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
