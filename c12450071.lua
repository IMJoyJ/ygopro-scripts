--プロキシー・F・マジシャン
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ②：这张卡所连接区有融合怪兽融合召唤的场合才能发动。从手卡把1只攻击力1000以下的怪兽特殊召唤。
function c12450071.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：作为效果怪兽2只的链接怪兽从额外卡组连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	-- ①：自己主要阶段才能发动。自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12450071,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,12450071)
	e1:SetTarget(c12450071.target)
	e1:SetOperation(c12450071.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区有融合怪兽融合召唤的场合才能发动。从手卡把1只攻击力1000以下的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12450071,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,12450072)
	e2:SetCondition(c12450071.spcon)
	e2:SetTarget(c12450071.sptg)
	e2:SetOperation(c12450071.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否不免疫这个效果，即能否被本效果作为融合素材使用（不免疫才可使用）。
function c12450071.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：判定额外卡组的怪兽是否为可融合召唤的融合怪兽，且能用给定素材组m（以及额外素材条件f）进行融合召唤。
function c12450071.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 目标函数（效果①发动时）：检查自己场上素材能否用于融合召唤，若普通素材不可行则检查连锁素材等替代素材；只要存在可融合召唤的融合怪兽即可发动。
function c12450071.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp可用的融合素材，并只保留场上的卡，因为效果①限定用自己场上的怪兽作为融合素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组是否存在至少1只可用当前场上素材作为融合素材进行融合召唤的融合怪兽。
		local res=Duel.IsExistingMatchingCard(c12450071.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家tp适用的“连锁素材”类替代融合素材效果，若有则返回该效果，否则nil。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在替代素材效果，则用其提供的新素材组mg2和素材条件mf，检查额外卡组是否还能融合召唤。
				res=Duel.IsExistingMatchingCard(c12450071.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理信息：本效果涉及从额外卡组将1只怪兽特殊召唤（融合召唤），供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的实际处理：选择融合怪兽、选择素材、送墓素材并融合召唤；若使用替代素材效果则按该效果流程处理。
function c12450071.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理时重新获取可用的场上融合素材，并排除不受本效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(c12450071.filter1,nil,e)
	-- 获取全部能用场上素材进行融合召唤的融合怪兽候选集合。
	local sg1=Duel.GetMatchingGroup(c12450071.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果处理时再次获取玩家适用的替代融合素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在替代素材效果，获取使用替代素材时可融合召唤的融合怪兽候选集合。
		sg2=Duel.GetMatchingGroup(c12450071.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示“请选择要特殊召唤的卡”的提示，供玩家选择融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判定所选融合怪兽是否走普通素材路线：若它不在替代素材候选内，或玩家选择不使用替代素材，则用普通素材融合召唤，否则走替代素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通可用素材组中选择融合怪兽tc所需的一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材以“效果+融合素材+融合召唤”的原因送去墓地，完成素材送墓。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合召唤成功作为一个独立时点，避免与素材送墓同处理导致错失诱发时点。
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤方式表侧表示特殊召唤到场上的可用区域。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在替代素材流程中，让玩家从替代素材组中选择融合怪兽tc所需的一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数：判断特殊召唤成功的怪兽是否为表侧表示且在指定组g（即这张卡所连接区）中的融合怪兽，并且其召唤方式为融合召唤。
function c12450071.cfilter(c,g)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION) and g:IsContains(c)
end
-- 过滤函数：从手卡中筛选攻击力1000以下且可以被特殊召唤的怪兽。
function c12450071.spfilter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件：这张卡所连接区有融合怪兽融合召唤成功，且一次特殊召唤事件中不包含这张卡自身（即不是这张卡被特殊召唤）。
function c12450071.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and eg:IsExists(c12450071.cfilter,1,nil,lg) and not eg:IsContains(e:GetHandler())
end
-- 效果②的发动目标检查：自己场上还有主怪兽区空格，且手卡有符合条件的怪兽，才能发动。
function c12450071.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在攻击力1000以下且可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c12450071.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：本效果涉及从手卡将1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的实际处理：若场上仍有空位，则从手卡选1只符合条件的怪兽特殊召唤。
function c12450071.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主怪兽区有空格，没有则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，供玩家选择手卡怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只符合条件的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c12450071.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的手卡怪兽以表侧攻击表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
