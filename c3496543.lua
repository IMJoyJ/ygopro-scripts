--白き森の罪宝
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有恶魔族·幻想魔族·魔法师族怪兽的其中任意种存在的场合，可以从以下效果选择1个发动。
-- ●从手卡把1只恶魔族·幻想魔族·魔法师族怪兽特殊召唤。
-- ●自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建并注册本卡的两个效果：①为魔法卡的发动效果，可选择手卡特招或融合召唤；②为被怪兽效果发动而送墓时盖放自己的诱发效果，并设置了各自1回合1次的限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有恶魔族·幻想魔族·魔法师族怪兽的其中任意种存在的场合，可以从以下效果选择1个发动。●从手卡把1只恶魔族·幻想魔族·魔法师族怪兽特殊召唤。●自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动效果"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.fscon)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- ①效果的发动条件函数：检查自己场上是否存在表侧表示且种族为恶魔族、幻想魔族或魔法师族的怪兽。
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1张满足表侧表示且种族为恶魔族/幻想魔族/魔法师族的怪兽，作为①效果可否发动的判定。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,0,1,nil,RACE_ILLUSION+RACE_SPELLCASTER+RACE_FIEND)
end
-- 定义手卡特招的怪兽筛选条件：怪兽须为恶魔族/幻想魔族/魔法师族，且能被效果特殊召唤，用于①的‘从手卡特殊召唤’选项。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER+RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义融合怪兽的筛选条件：怪兽须为融合怪兽、可以融合召唤特殊召唤，且能用当前选择的素材组进行融合召唤，用于①的‘融合召唤’选项。
function s.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的发动目标处理函数：判断两个选项（手卡特招/融合召唤）是否可行，若都可行则让玩家选择其中1个，再设置对应的效果类别与操作信息。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位，用于判断‘从手卡特殊召唤’选项是否可行。
	local res1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在满足种族条件且可被效果特殊召唤的怪兽，确定‘从手卡特殊召唤’选项可选。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local chkf=tp
	-- 获取自己可用于融合召唤的素材组（手卡·场上的怪兽及额外融合素材效果），并排除不受效果影响的卡，作为普通融合召唤的素材候选。
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 检查额外卡组是否存在能用当前素材组进行融合召唤的融合怪兽，确定‘融合召唤’选项可选。
	local res2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res2 then
		-- 获取自己适用的‘连锁素材’类替代融合效果（若有），用于扩展融合素材选择范围。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 若存在连锁素材效果，则使用其提供的素材组和条件，重新检查额外卡组是否存在可融合召唤的融合怪兽。
			res2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	if chk==0 then return res1 or res2 end
	local op=0
	if res1 and not res2 then
		-- 当只有手卡特招选项可行时，向对方玩家提示将发动‘从手卡特殊召唤’选项。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))  --"从手卡特殊召唤"
		op=1
	end
	if res2 and not res1 then
		-- 当只有融合召唤选项可行时，向对方玩家提示将发动‘融合召唤’选项。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))  --"融合召唤"
		op=2
	end
	if res1 and res2 then
		-- 当两个选项都可行时，弹出选择界面，让玩家从‘从手卡特殊召唤’和‘融合召唤’中选择1个。
		op=aux.SelectFromOptions(tp,
			{res1,aux.Stringid(id,2),1},  --"从手卡特殊召唤"
			{res2,aux.Stringid(id,3),2})  --"融合召唤"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 若选择手卡特招，设置效果类别为特殊召唤，并登记操作信息：从手卡特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		-- 若选择融合召唤，设置效果类别为特殊召唤+融合召唤，并登记操作信息：从额外卡组将1只融合怪兽融合召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
-- ①效果的处理函数：根据发动时选择的选项执行，选1则从手卡特殊召唤1只符合条件的怪兽，选2则以手卡·场上的怪兽为素材进行融合召唤。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 执行手卡特招前，再次确认自己主要怪兽区仍有空位。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 弹出‘请选择要特殊召唤的卡’的提示消息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手卡中选择1只满足种族条件且可被效果特殊召唤的怪兽。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		local chkf=tp
		-- 执行融合召唤前，获取可用的融合素材组（手卡·场上怪兽），并排除不受效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		-- 获取额外卡组中所有能用普通素材组融合召唤的融合怪兽候选。
		local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2,sg2=nil,nil
		-- 获取自己适用的‘连锁素材’类替代融合效果（若有）。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 若存在连锁素材效果，使用其素材组获取额外的可融合召唤的融合怪兽候选。
			sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if #sg1>0 or (sg2~=nil and #sg2>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			::cancel::
			-- 弹出‘请选择要特殊召唤的卡’的提示消息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=sg:Select(tp,1,1,nil):GetFirst()
			-- 判断选中的融合怪兽应使用普通素材还是连锁素材效果进行融合：若它仅在普通素材候选中，或不在连锁素材候选中，或玩家选择不使用连锁素材，则走普通融合流程。
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 从普通素材组中为选定的融合怪兽选择融合素材。
				local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				if #mat==0 then goto cancel end
				tc:SetMaterial(mat)
				-- 将选择的融合素材以效果+素材+融合的理由送去墓地。
				Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理，使后续的融合召唤成为不同时处理，以避免错过时点。
				Duel.BreakEffect()
				-- 以融合召唤的方式将选定的融合怪兽特殊召唤到自己场上。
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce~=nil then
				-- 若使用连锁素材效果，则从连锁素材提供的素材组中为选定的融合怪兽选择融合素材。
				local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				if #mat==0 then goto cancel end
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat)
			end
			tc:CompleteProcedure()
		end
	end
end
-- ②效果的发动条件函数：这张卡作为怪兽效果发动的COST被送去墓地，且那个发动是怪兽效果的发动。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动目标处理函数：检查此卡是否可以盖放，并登记‘离开墓地’的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 登记操作信息：此卡将从墓地离开（被盖放到场上）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果的处理函数：若此卡仍与效果关联且不受王家长眠之谷影响，则将其盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联且不受王家长眠之谷影响后，将其盖放到自己场上。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then Duel.SSet(tp,c) end
end
