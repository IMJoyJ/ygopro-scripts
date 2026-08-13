--烙印融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：自己的手卡·卡组·场上的怪兽2只作为融合素材，把以「阿不思的落胤」为融合素材的1只融合怪兽融合召唤。
function c44362883.initial_effect(c)
	-- 注册卡名记载，将「阿不思的落胤」（卡号68468459）记录到此卡上，用于后续通过 aux.IsMaterialListCode 判断融合怪兽是否以「阿不思的落胤」为融合素材。
	aux.AddCodeList(c,68468459)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。①：自己的手卡·卡组·场上的怪兽2只作为融合素材，把以「阿不思的落胤」为融合素材的1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44362883+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c44362883.cost)
	e1:SetTarget(c44362883.target)
	e1:SetOperation(c44362883.activate)
	c:RegisterEffect(e1)
	-- 为当前玩家注册一个特殊召唤活动计数器，专门记录从额外卡组特殊召唤非融合怪兽的操作次数，用于发动前检查自肃条件。
	Duel.AddCustomActivityCounter(44362883,ACTIVITY_SPSUMMON,c44362883.counterfilter)
end
-- 计数器过滤函数：只有“从额外卡组特殊召唤且不是融合怪兽”的操作才会计数，其他特殊召唤不会触发自肃限制。
function c44362883.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- 发动代价：检查本回合是否尚未进行过非融合怪兽的额外特殊召唤，若满足则给己方附加“不能从额外卡组特殊召唤非融合怪兽”的誓约效果。
function c44362883.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方本回合的特殊召唤计数是否为0，即不能已经出现过从额外卡组特殊召唤非融合怪兽的行为。
	if chk==0 then return Duel.GetCustomActivityCount(44362883,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。①：自己的手卡·卡组·场上的怪兽2只作为融合素材，把以「阿不思的落胤」为融合素材的1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44362883.splimit)
	-- 将自肃效果注册到场上，使它作为永续效果影响己方玩家，直到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤条件：从额外卡组特殊召唤的怪兽如果不是融合怪兽，则不能进行特殊召唤。
function c44362883.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
-- 定义卡组中可作为融合素材的怪兽条件：必须是怪兽、能作为融合素材、且可以被送去墓地。
function c44362883.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 定义素材过滤条件：素材不能被当前效果免疫，确保之后处理素材时不会因免疫而无效。
function c44362883.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义融合怪兽候选的筛选条件：必须是融合怪兽、记载「阿不思的落胤」为融合素材、满足额外素材条件，并且可以被融合召唤特殊召唤。
function c44362883.filter2(c,e,tp,m,f,chkf)
	-- 检查候选融合怪兽是否为融合怪兽、是否记载「阿不思的落胤」为素材，以及是否满足特殊召唤条件。
	if not (c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 临时设置额外的融合素材检查函数，使后续的 CheckFusionMaterial 校验素材数量不超过2且必须包含「阿不思的落胤」。
	aux.FCheckAdditional=c.branded_fusion_check or c44362883.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除额外融合素材检查函数，避免影响后续其他融合判断。
	aux.FCheckAdditional=nil
	return res
end
-- 额外的素材合法性检查：融合素材组数量不超过2，且其中至少存在1张「阿不思的落胤」（卡号68468459）。
function c44362883.fcheck(tp,sg,fc)
	return sg:GetCount()<=2 and sg:IsExists(Card.IsFusionCode,1,nil,68468459)
end
-- 发动时的目标判定：确认能够从手卡·卡组·场上选取2只素材，将记载「阿不思的落胤」的融合怪兽融合召唤；同时判断是否存在可用的连锁素材效果。
function c44362883.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取己方当前可用的融合素材组，通常包含手卡和场上的怪兽，以及受额外融合素材效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 从卡组中筛选出满足 filter0 条件的怪兽，即可作为融合素材且能送去墓地的怪兽，并加入素材组。
		local mg2=Duel.GetMatchingGroup(c44362883.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在符合条件的融合怪兽，能够用当前素材组完成融合召唤。
		local res=Duel.IsExistingMatchingCard(c44362883.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取己方受到的连锁素材效果（如“融合”相关的替代素材效果），用于扩展素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材效果，则用该效果提供的素材组再次检查额外卡组中是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c44362883.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向系统登记本次操作包含从额外卡组特殊召唤1只怪兽，用于其他卡片对特殊召唤的响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时执行融合召唤：从可用素材中选择融合素材，将选择的融合怪兽以融合召唤方式特殊召唤；若使用了连锁素材效果，则按对应效果逻辑处理。
function c44362883.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取己方可作为融合素材的怪兽，并排除对当前效果免疫的卡，避免选择无法被效果处理的素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c44362883.filter1,nil,e)
	-- 从卡组中获取可作为融合素材的怪兽，加入到素材组中，使卡组也能作为素材来源。
	local mg2=Duel.GetMatchingGroup(c44362883.filter0,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 根据当前素材组，从额外卡组筛选出所有可融合召唤的融合怪兽候选。
	local sg1=Duel.GetMatchingGroup(c44362883.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果，用于取得额外的融合素材组。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材效果提供的素材组，从额外卡组筛选出额外的融合怪兽候选。
		sg2=Duel.GetMatchingGroup(c44362883.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出“请选择要特殊召唤的卡”的选择提示，让玩家从候选融合怪兽中选择1只。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽是否来自普通素材组，并且（不存在连锁素材组、或该怪兽不在连锁素材组、或玩家选择不使用连锁素材效果）时，走普通融合召唤流程；否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 设置额外的融合素材检查函数，要求素材数量不超过2且必须包含「阿不思的落胤」，以便下一步选择素材时满足卡牌效果要求。
			aux.FCheckAdditional=tc.branded_fusion_check or c44362883.fcheck
			-- 让玩家从普通素材组中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除额外的融合素材检查函数，避免影响后续其他处理。
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将作为融合素材的怪兽送去墓地，作为融合召唤的素材消耗。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使随后的融合召唤被视为独立处理，避免错失时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以表侧攻击表示、融合召唤方式特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材效果时，让玩家从连锁素材效果提供的素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
