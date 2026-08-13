--影依の偽典
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段才能发动。自己的场上·墓地的怪兽作为融合素材除外，把1只「影依」融合怪兽融合召唤。那之后，可以把属性和这个效果特殊召唤的怪兽相同的对方场上1只怪兽送去墓地。这个效果特殊召唤的怪兽不能直接攻击。
function c21011044.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己·对方的主要阶段才能发动。自己的场上·墓地的怪兽作为融合素材除外，把1只「影依」融合怪兽融合召唤。那之后，可以把属性和这个效果特殊召唤的怪兽相同的对方场上1只怪兽送去墓地。这个效果特殊召唤的怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,21011044)
	e1:SetCondition(c21011044.condition)
	e1:SetTarget(c21011044.target)
	e1:SetOperation(c21011044.activate)
	c:RegisterEffect(e1)
end
-- 筛选场上满足除外条件的卡，作为可作为融合素材的场上的怪兽候选。
function c21011044.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 筛选场上可除外且不免疫此效果的卡，用于实际选择融合素材。
function c21011044.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中为「影依」融合怪兽且能用给定素材融合召唤、并能被融合特殊召唤的怪兽。
function c21011044.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9d) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选墓地中为怪兽且可作为融合素材并能被除外的卡。
function c21011044.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 效果发动条件：仅在自己·对方的主要阶段才能发动。
function c21011044.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果发动合法性检查：确认能用场上·墓地的素材融合召唤「影依」融合怪兽，并登记特殊召唤、除外、送墓的操作信息。
function c21011044.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可除外的融合素材候选。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c21011044.filter0,nil)
		-- 获取自己墓地中可除外且可作为融合素材的怪兽候选。
		local mg2=Duel.GetMatchingGroup(c21011044.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可用当前素材融合召唤的「影依」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c21011044.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取自己受到的效果外融合素材（如连锁素材）的效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材，用其提供的素材组再次检查可融合召唤的「影依」融合怪兽。
				res=Duel.IsExistingMatchingCard(c21011044.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次效果会从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 登记本次效果会从场上或墓地除外融合素材。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 登记本次效果可能将对方场上1只怪兽送去墓地，数量待处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_MZONE)
end
-- 效果处理：选择融合素材并除外、融合召唤「影依」融合怪兽，使其不能直接攻击，并可选将对方场上同属性怪兽送去墓地。
function c21011044.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取场上可除外且不免疫此效果的融合素材候选。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c21011044.filter1,nil,e)
	-- 获取墓地中可除外且可作为融合素材的怪兽候选。
	local mg2=Duel.GetMatchingGroup(c21011044.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 筛选额外卡组中可用当前素材融合召唤的「影依」融合怪兽。
	local sg1=Duel.GetMatchingGroup(c21011044.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果，用于扩展融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材，筛选可用其提供的素材融合召唤的「影依」融合怪兽。
		sg2=Duel.GetMatchingGroup(c21011044.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽应使用常规素材还是连锁素材进行融合；若两者均可，询问玩家是否使用连锁素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从常规素材候选中为选择的融合怪兽选出实际融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材表侧表示除外，作为融合召唤的素材。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使融合召唤作为独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材提供的素材组中为融合怪兽选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		-- 那之后，可以把属性和这个效果特殊召唤的怪兽相同的对方场上1只怪兽送去墓地。这个效果特殊召唤的怪兽不能直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(21011044,1))  --"「影依的伪典」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local attr=tc:GetAttribute()
		-- 判断特殊召唤的怪兽表侧表示，且对方场上存在与其属性相同且可送去墓地的怪兽。
		if tc:IsFaceup() and Duel.IsExistingMatchingCard(c21011044.tgfilter,tp,0,LOCATION_MZONE,1,nil,attr)
			-- 询问玩家是否将对方场上1只属性相同的怪兽送去墓地。
			and Duel.SelectYesNo(tp,aux.Stringid(21011044,0)) then  --"是否选对方怪兽送去墓地？"
			-- 再次中断效果处理，使送墓作为后续独立处理。
			Duel.BreakEffect()
			-- 选择对方场上一只表侧表示且属性与融合召唤怪兽相同的怪兽。
			local g=Duel.SelectMatchingCard(tp,c21011044.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,attr)
			-- 为选中的怪兽显示选择动画并记录为对象。
			Duel.HintSelection(g)
			-- 将选中的对方怪兽送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 筛选对方场上表侧表示、属性与指定属性相同且可送去墓地的怪兽。
function c21011044.tgfilter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr) and c:IsAbleToGrave()
end
