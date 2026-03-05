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
	-- 效果原文内容：①：自己·对方的主要阶段才能发动。自己的场上·墓地的怪兽作为融合素材除外，把1只「影依」融合怪兽融合召唤。那之后，可以把属性和这个效果特殊召唤的怪兽相同的对方场上1只怪兽送去墓地。这个效果特殊召唤的怪兽不能直接攻击。
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
-- 过滤函数：场上或墓地的怪兽，且能除外
function c21011044.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 过滤函数：场上或墓地的怪兽，且能除外，且未免疫此效果
function c21011044.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：融合怪兽，且为影依卡组，且能特殊召唤，且能作为融合素材
function c21011044.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9d) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤函数：怪兽，且能作为融合素材，且能除外
function c21011044.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 效果作用：判断是否在主要阶段
function c21011044.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否在主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果作用：判断是否满足发动条件
function c21011044.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 效果作用：获取玩家可用的融合素材组，并过滤出满足条件的卡片
		local mg1=Duel.GetFusionMaterial(tp):Filter(c21011044.filter0,nil)
		-- 效果作用：获取玩家墓地中的怪兽组，并过滤出满足条件的卡片
		local mg2=Duel.GetMatchingGroup(c21011044.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 效果作用：检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c21011044.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 效果作用：获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 效果作用：检查是否存在满足条件的融合怪兽（通过连锁素材效果）
				res=Duel.IsExistingMatchingCard(c21011044.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 效果作用：设置操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 效果作用：设置操作信息，表示将除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 效果作用：设置操作信息，表示将对方场上1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_MZONE)
end
-- 效果作用：处理融合召唤的主逻辑
function c21011044.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果作用：获取玩家可用的融合素材组，并过滤出满足条件的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c21011044.filter1,nil,e)
	-- 效果作用：获取玩家墓地中的怪兽组，并过滤出满足条件的卡片
	local mg2=Duel.GetMatchingGroup(c21011044.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 效果作用：获取满足条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c21011044.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 效果作用：获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果作用：获取满足条件的融合怪兽组（通过连锁素材效果）
		sg2=Duel.GetMatchingGroup(c21011044.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 效果作用：提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 效果作用：判断是否使用普通融合召唤方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 效果作用：选择融合召唤的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 效果作用：将融合素材除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 效果作用：中断当前效果
			Duel.BreakEffect()
			-- 效果作用：特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 效果作用：选择融合召唤的素材（通过连锁素材效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		-- 效果原文内容：这个效果特殊召唤的怪兽不能直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(21011044,1))  --"「影依的伪典」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local attr=tc:GetAttribute()
		-- 效果作用：判断对方场上是否存在属性相同的怪兽
		if tc:IsFaceup() and Duel.IsExistingMatchingCard(c21011044.tgfilter,tp,0,LOCATION_MZONE,1,nil,attr)
			-- 效果作用：询问玩家是否选择对方怪兽送去墓地
			and Duel.SelectYesNo(tp,aux.Stringid(21011044,0)) then  --"是否选对方怪兽送去墓地？"
			-- 效果作用：中断当前效果
			Duel.BreakEffect()
			-- 效果作用：选择对方场上属性相同的怪兽
			local g=Duel.SelectMatchingCard(tp,c21011044.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,attr)
			-- 效果作用：显示选中怪兽的动画效果
			Duel.HintSelection(g)
			-- 效果作用：将选中的怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 过滤函数：场上表侧表示的怪兽，且属性匹配，且能送去墓地
function c21011044.tgfilter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr) and c:IsAbleToGrave()
end
