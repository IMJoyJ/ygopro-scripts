--古代の機械競闘
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的怪兽区域的「古代的机械巨人」以及有那个卡名记述的怪兽不受对方发动的怪兽的效果影响。
-- ②：对方场上有怪兽存在的场合才能发动。包含自己场上的「古代的机械巨人」的自己的场上·墓地的怪兽作为融合素材除外，把有「古代的机械巨人」的卡名记述的1只融合怪兽融合召唤。这个效果特殊召唤的怪兽在同1次的战斗阶段中可以作3次攻击。
function c53541822.initial_effect(c)
	-- 将「古代的机械巨人」(83104731) 登记为这张卡效果文本中记述的卡名，供后续 aux.IsCodeListed 判断使用。
	aux.AddCodeList(c,83104731)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己的怪兽区域的「古代的机械巨人」以及有那个卡名记述的怪兽不受对方发动的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c53541822.indtg)
	e1:SetValue(c53541822.efilter)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方场上有怪兽存在的场合才能发动。包含自己场上的「古代的机械巨人」的自己的场上·墓地的怪兽作为融合素材除外，把有「古代的机械巨人」的卡名记述的1只融合怪兽融合召唤。这个效果特殊召唤的怪兽在同1次的战斗阶段中可以作3次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,53541822)
	e2:SetCondition(c53541822.condition)
	e2:SetTarget(c53541822.target)
	e2:SetOperation(c53541822.activate)
	c:RegisterEffect(e2)
end
c53541822.fusion_effect=true
-- 定义免疫效果的对象判定函数：只有「古代的机械巨人」自身或效果文本记载了「古代的机械巨人」的怪兽才享受免疫保护。
function c53541822.indtg(e,c)
	-- 判断怪兽是否为卡号83104731，或该卡效果文本中记述了83104731。
	return c:IsCode(83104731) or aux.IsCodeListed(c,83104731)
end
-- 定义免疫效果的过滤条件：仅免疫由对方发动、且为怪兽效果的已发动效果。
function c53541822.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤函数：卡片在场上且可以被除外，用于发动前筛选可用的融合素材。
function c53541822.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 过滤函数：卡片在场上、可除外，且不免疫于本次效果，用于处理时实际选择素材。
function c53541822.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：从额外卡组筛选可融合召唤的融合怪兽；要求是融合怪兽、卡名记述了「古代的机械巨人」、满足额外素材条件、能被融合特殊召唤且能用当前素材完成融合。
function c53541822.filter2(c,e,tp,m,f,chkf)
	-- 候选融合怪兽的前半条件：必须是融合怪兽，且效果文本中记述了「古代的机械巨人」。
	return c:IsType(TYPE_FUSION) and aux.IsCodeListed(c,83104731) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤函数：墓地中可作为融合素材且可除外的怪兽，用于补足“自己的场上·墓地”中的墓地来源。
function c53541822.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 定义②效果的发动条件：对方场上有怪兽存在。
function c53541822.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：查看对方怪兽区，存在至少1只怪兽。
	return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
end
-- 定义额外素材检查函数：选定的融合素材中必须包含1只自己场上的「古代的机械巨人」。
function c53541822.fcheck(tp,sg,fc)
	return sg:IsExists(c53541822.filter,1,nil)
end
-- 过滤函数：卡片位于场上且卡号为83104731，用于确认素材包含自己场上的「古代的机械巨人」。
function c53541822.filter(c)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsCode(83104731)
end
-- ②效果发动时的合法性检查：收集场上·墓地可除外的融合素材、设置必须包含场上古代机械巨人的额外检查，确认额外卡组中存在可融合召唤的怪兽；若存在连锁素材效果也一并检查。通过后写入特殊召唤/除外等操作信息。
function c53541822.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得玩家可用的融合素材后，筛选出场上可除外的怪兽作为素材候选（对应“自己的场上”）。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c53541822.filter0,nil)
		-- 取得墓地中可作为融合素材且可除外的怪兽，并入素材候选（对应“自己的墓地”）。
		local mg2=Duel.GetMatchingGroup(c53541822.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 设置额外的融合素材检查函数，强制要求最终素材中包含自己场上的「古代的机械巨人」。
		aux.FCheckAdditional=c53541822.fcheck
		-- 检查额外卡组中是否存在可用当前素材（场上+墓地）融合召唤的融合怪兽。
		local res=Duel.IsExistingMatchingCard(c53541822.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得玩家适用的连锁素材/替代融合素材效果（若有），以便后续使用替代素材融合召唤。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若普通素材无法融合召唤，再使用连锁素材效果提供的素材检查额外卡组中是否存在可融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(c53541822.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 清除临时设置的额外素材检查函数，避免影响后续其他融合素材判定。
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置操作信息：本效果将进行1次从额外卡组的特殊召唤（融合召唤），特殊召唤到自己的怪兽区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本效果会从场上·墓地除外融合素材。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 设置操作信息：声明对方场上的怪兽可能被送去墓地（数量为0），用于完善效果分类/连锁检测，实际不会送墓。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_MZONE)
end
-- ②效果处理：重新获取可除外的融合素材（排除免疫卡）、补入墓地素材，设置素材必须包含场上古代机械巨人的额外检查；筛选可融合召唤的融合怪兽（含连锁素材方案）；选择怪兽后选择素材并将其除外，执行融合召唤；随后给该怪兽附加同一战斗阶段可攻击3次的效果，最后清除额外检查。
function c53541822.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 处理时取得场上可除外的融合素材，并通过 filter1 排除不受本效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c53541822.filter1,nil,e)
	-- 处理时取得墓地可除外的融合素材，并入候选素材。
	local mg2=Duel.GetMatchingGroup(c53541822.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 设置额外的融合素材检查函数，强制实际选择的素材中包含自己场上的「古代的机械巨人」。
	aux.FCheckAdditional=c53541822.fcheck
	-- 使用普通融合素材（场上+墓地）筛选额外卡组中可融合召唤的融合怪兽。
	local sg1=Duel.GetMatchingGroup(c53541822.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 取得连锁素材效果（若有），用于使用替代素材进行融合召唤。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材效果提供的素材，筛选额外卡组中可融合召唤的融合怪兽。
		sg2=Duel.GetMatchingGroup(c53541822.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出“请选择要特殊召唤的卡”的提示，让玩家从候选融合怪兽中选择1只。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断应使用普通融合素材还是连锁素材：若选中的怪兽不在连锁素材候选中，或玩家选择不使用连锁素材，则走普通融合流程；否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组中选择一组满足条件的融合素材（必须包含自己场上的「古代的机械巨人」）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材以表侧表示除外，作为融合召唤的素材使用。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使随后的融合召唤与附加攻击次数效果在不同时点处理，避免错误合并时点。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示进行融合召唤到我方怪兽区。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材效果提供的素材中选择一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		-- 这个效果特殊召唤的怪兽在同1次的战斗阶段中可以作3次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(53541822,2))  --"「古代的机械竞斗」的效果特殊召唤"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
	-- 清除临时设置的额外素材检查函数。
	aux.FCheckAdditional=nil
end
