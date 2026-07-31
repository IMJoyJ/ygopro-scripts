--捕食植物サンデウ・キンジー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己要作为融合素材的有捕食指示物放置的怪兽的属性当作暗属性使用。
-- ②：自己主要阶段才能发动。暗属性融合怪兽卡决定的包含场上的这张卡的融合素材怪兽从自己的手卡·场上以及对方场上的有捕食指示物放置的怪兽之中选出送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c89181134.initial_effect(c)
	-- 初始化卡片效果：注册融合素材属性变更永续效果、以及主要阶段包含自身进行融合召唤的起动效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_FUSION_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c89181134.attrtg)
	e1:SetValue(c89181134.attrval)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己要作为融合素材的有捕食指示物放置的怪兽的属性当作暗属性使用。
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
-- ②：自己主要阶段才能发动。暗属性融合怪兽卡决定的包含场上的这张卡的融合素材怪兽从自己的手卡·场上以及对方场上的有捕食指示物放置的怪兽之中选出送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c89181134.attrtg(e,c)
	return c:GetCounter(0x1041)>0
end
-- 属性变更条件过滤：如果作为融合素材的怪兽带有捕食指示物，将其属性当作暗属性
function c89181134.attrval(e,c,rp)
	if rp==e:GetHandlerPlayer() then
		return ATTRIBUTE_DARK
	else return c:GetAttribute() end
end
-- 融合素材组合检查：必须包含场上的这张卡
function c89181134.filter0(c)
	return c:IsCanBeFusionMaterial() and c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 额外素材包含判断：检查素材组中是否包含场上的此卡
function c89181134.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 对方场上融合素材过滤条件：带有捕食指示物且可作为融合素材送去墓地
function c89181134.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 己方手牌·场上融合素材过滤条件：可以作为融合素材送去墓地
function c89181134.filter3(c,e)
	return c89181134.filter0(c) and not c:IsImmuneToEffect(e)
end
-- 对方场上融合素材过滤条件：带捕食指示物且可作为融合素材送去墓地
function c89181134.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 融合怪兽过滤条件：暗属性融合怪兽，且可以用指定素材进行融合召唤
		local mg1=Duel.GetFusionMaterial(tp)
		-- ②效果发动准备：检查是否存在合法的暗属性融合怪兽及其素材并设置操作信息
		local mg2=Duel.GetMatchingGroup(c89181134.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 获取己方及对方场上符合条件的融合素材集合
		local res=Duel.IsExistingMatchingCard(c89181134.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 检查是否存在合法的融合召唤分支
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 设置连锁操作信息：从额外卡组特殊召唤1只融合怪兽
				res=Duel.IsExistingMatchingCard(c89181134.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息：将融合素材送去墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：选择融合素材送去墓地，并从额外卡组融合召唤暗属性融合怪兽
function c89181134.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or (c:IsControler(1-tp) and c:GetCounter(0x1041)<=0) then return end
	-- 获取卡片自身句柄
	local mg1=Duel.GetFusionMaterial(tp):Filter(c89181134.filter1,nil,e)
	-- 检查此卡是否仍关联当前效果且不受效果影响
	local mg2=Duel.GetMatchingGroup(c89181134.filter3,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 提示玩家从额外卡组选择1只合法的暗属性融合怪兽
	local sg1=Duel.GetMatchingGroup(c89181134.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取选中的融合怪兽
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 选择满足条件的融合素材（必须包含此卡）
		sg2=Duel.GetMatchingGroup(c89181134.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 为融合怪兽设置选定的融合素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 将选中的融合素材卡片送去墓地
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 连接效果块（分隔送去墓地与融合召唤的操作）
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将融合怪兽以融合召唤形式表侧表示特殊召唤
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 完成融合怪兽的正规召唤手续
			Duel.BreakEffect()
			-- 设置额外的融合素材组合检查函数
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 设置额外的融合素材组包含检查函数
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
