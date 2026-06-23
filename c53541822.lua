--古代の機械競闘
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的怪兽区域的「古代的机械巨人」以及有那个卡名记述的怪兽不受对方发动的怪兽的效果影响。
-- ②：对方场上有怪兽存在的场合才能发动。包含自己场上的「古代的机械巨人」的自己的场上·墓地的怪兽作为融合素材除外，把有「古代的机械巨人」的卡名记述的1只融合怪兽融合召唤。这个效果特殊召唤的怪兽在同1次的战斗阶段中可以作3次攻击。
function c53541822.initial_effect(c)
	-- 记录此卡效果文本上记载着「古代的机械巨人」这张卡名
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
	-- ②：对方场上有怪兽存在的场合才能发动。包含自己场上的「古代的机械巨人」的自己的场上·墓地的怪兽作为融合素材除外，把有「古代的机械巨人」的卡名记述的1只融合怪兽融合召唤。这个效果特殊召唤的怪兽在同1次的战斗阶段中可以作3次攻击。
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
-- 判断目标怪兽是否为「古代的机械巨人」或记载有其卡名
function c53541822.indtg(e,c)
	-- 判断目标怪兽是否为「古代的机械巨人」或记载有其卡名
	return c:IsCode(83104731) or aux.IsCodeListed(c,83104731)
end
-- 判断效果是否为对方发动的怪兽效果
function c53541822.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤场上可除外的卡
function c53541822.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 过滤场上可除外且未免疫效果的卡
function c53541822.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤满足融合召唤条件的融合怪兽
function c53541822.filter2(c,e,tp,m,f,chkf)
	-- 过滤满足融合召唤条件的融合怪兽
	return c:IsType(TYPE_FUSION) and aux.IsCodeListed(c,83104731) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤可作为融合素材的怪兽
function c53541822.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 判断对方场上是否存在怪兽
function c53541822.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上是否存在怪兽
	return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
end
-- 检查融合素材中是否包含「古代的机械巨人」
function c53541822.fcheck(tp,sg,fc)
	return sg:IsExists(c53541822.filter,1,nil)
end
-- 判断目标是否为场上的「古代的机械巨人」
function c53541822.filter(c)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsCode(83104731)
end
-- 设置效果发动时的处理信息
function c53541822.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组
		local mg1=Duel.GetFusionMaterial(tp):Filter(c53541822.filter0,nil)
		-- 获取玩家墓地中的可除外怪兽
		local mg2=Duel.GetMatchingGroup(c53541822.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 设置融合检查附加条件
		aux.FCheckAdditional=c53541822.fcheck
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c53541822.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c53541822.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 清除融合检查附加条件
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 设置操作信息：将对方场上怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_MZONE)
end
-- 处理效果发动
function c53541822.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c53541822.filter1,nil,e)
	-- 获取玩家墓地中的可除外怪兽
	local mg2=Duel.GetMatchingGroup(c53541822.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 设置融合检查附加条件
	aux.FCheckAdditional=c53541822.fcheck
	-- 获取满足融合召唤条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c53541822.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足融合召唤条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c53541822.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一种融合召唤方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤的素材
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
	-- 清除融合检查附加条件
	aux.FCheckAdditional=nil
end
