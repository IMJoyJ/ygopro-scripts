--捕食植物サンデウ・キンジー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己要作为融合素材的有捕食指示物放置的怪兽的属性当作暗属性使用。
-- ②：自己主要阶段才能发动。暗属性融合怪兽卡决定的包含场上的这张卡的融合素材怪兽从自己的手卡·场上以及对方场上的有捕食指示物放置的怪兽之中选出送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c89181134.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己要作为融合素材的有捕食指示物放置的怪兽的属性当作暗属性使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_FUSION_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c89181134.attrtg)
	e1:SetValue(c89181134.attrval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。暗属性融合怪兽卡决定的包含场上的这张卡的融合素材怪兽从自己的手卡·场上以及对方场上的有捕食指示物放置的怪兽之中选出送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89181134,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,89181134)
	e2:SetTarget(c89181134.target)
	e2:SetOperation(c89181134.operation)
	c:RegisterEffect(e2)
end
c89181134.mentioned_counter={
	[0x1041]=true,
}
-- 判断目标怪兽是否有捕食指示物
function c89181134.attrtg(e,c)
	return c:GetCounter(0x1041)>0
end
-- 如果是自己要作为融合素材，则属性当作暗属性使用，否则属性不变
function c89181134.attrval(e,c,rp)
	if rp==e:GetHandlerPlayer() then
		return ATTRIBUTE_DARK
	else return c:GetAttribute() end
end
-- 检查怪兽是否能作为融合素材，表侧表示且有捕食指示物
function c89181134.filter0(c)
	return c:IsCanBeFusionMaterial() and c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 检查怪兽是否不受该效果影响
function c89181134.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 检查该怪兽是否是暗属性融合怪兽，能被特殊召唤且能满足融合素材条件
function c89181134.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 检查怪兽是否有捕食指示物且不受该效果影响
function c89181134.filter3(c,e)
	return c89181134.filter0(c) and not c:IsImmuneToEffect(e)
end
-- 融合召唤效果的目标设定
function c89181134.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取自己可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 获取对方场上有捕食指示物的怪兽
		local mg2=Duel.GetMatchingGroup(c89181134.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 检查是否有可融合召唤的暗属性融合怪兽
		local res=Duel.IsExistingMatchingCard(c89181134.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取适用的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在使用连锁素材的情况下检查是否有可融合召唤的暗属性怪兽
				res=Duel.IsExistingMatchingCard(c89181134.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤融合怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理
function c89181134.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or (c:IsControler(1-tp) and c:GetCounter(0x1041)<=0) then return end
	-- 获取自己可用的不受此效果影响的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c89181134.filter1,nil,e)
	-- 获取对方场上有捕食指示物且不受此效果影响的怪兽
	local mg2=Duel.GetMatchingGroup(c89181134.filter3,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 获取可融合召唤的暗属性融合怪兽集合
	local sg1=Duel.GetMatchingGroup(c89181134.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取适用的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 在使用连锁素材的情况获取可融合召唤的暗属性怪兽集合
		sg2=Duel.GetMatchingGroup(c89181134.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 如果选中的怪兽在普通融合集合中且不需要或不选择使用连锁素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，造成错时点
			Duel.BreakEffect()
			-- 将该融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材的情况下选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
