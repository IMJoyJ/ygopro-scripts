--召喚魔術－「杯」
local s,id,o=GetID()
-- 初始化卡片效果：注册融合召唤「召唤兽」融合怪兽的发动效果
function s.initial_effect(c)
	-- ①：自己场上·墓地·除外状态有「召唤兽」卡存在的场合才能发动。从以下效果选择1个适用。●将自己手卡·场地1只怪兽和自己卡组1只怪兽除外，把1只「召唤兽」融合怪兽融合召唤。●将自己场地1只表侧表示怪兽和对方场地1只表侧表示怪兽除外，把1只「召唤兽」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动条件过滤：自己场上·墓地·除外状态的「召唤兽」卡
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1e1)
end
-- 发动条件检查：自己场上·墓地·除外状态是否存在「召唤兽」卡
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上·墓地·除外状态是否存在满足条件的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
-- 分支1手卡·场地融合素材过滤：不受效果影响且可除外的怪兽
function s.fmfilter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsAbleToRemove()
end
-- 分支2自己场地融合素材过滤：自己场地不受效果影响且可除外的怪兽
function s.fmfilter2(c,e)
	return c:IsLocation(LOCATION_MZONE) and not c:IsImmuneToEffect(e)
		and c:IsAbleToRemove()
end
-- 分支1卡组融合素材过滤：卡组中可作为融合素材且可除外的怪兽
function s.dmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 分支2对方场地融合素材过滤：对方场地表侧表示、可作为融合素材且可除外不受影响的怪兽
function s.cmfilter(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
		and not c:IsImmuneToEffect(e)
end
-- 分支1融合怪兽过滤：可用手卡/场地+卡组素材融合召唤的「召唤兽」融合怪兽
function s.fspfilter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置分支1素材检查回调：限制手卡/场地1张+卡组1张
	aux.FCheckAdditional=s.fcheck1
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 重置融合素材检查回调
	aux.FCheckAdditional=nil
	return res
end
-- 分支2融合怪兽过滤：可用自己场地+对方场地素材融合召唤的「召唤兽」融合怪兽
function s.fspfilter2(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置分支2素材检查回调：限制自己场地1张+对方场地1张
	aux.FCheckAdditional=s.fcheck2
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 重置融合素材检查回调
	aux.FCheckAdditional=nil
	return res
end
-- 分支1素材位置检查：融合素材必须是手卡·场地1张与卡组1张
function s.fcheck1(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD)==1
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==1
end
-- 分支2素材控制者检查：融合素材必须是自己场地1张与对方场地1张
function s.fcheck2(tp,sg,fc)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
		and sg:FilterCount(Card.IsControler,nil,1-tp)==1
end
-- 效果发动准备：检查两种分支的融合召唤可行性并由玩家选择分支
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取自己手卡·场地可用的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter1,nil,e)
	-- 获取卡组中可用的融合素材
	local mg2=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 获取自己场地可用的融合素材
	local mg3=Duel.GetFusionMaterial(tp):Filter(s.fmfilter2,nil,e)
	-- 获取对方场地可用的融合素材
	local mg4=Duel.GetMatchingGroup(s.cmfilter,tp,0,LOCATION_MZONE,nil,e)
	mg3:Merge(mg4)
	-- 检查分支1（手卡/场地+卡组素材）是否能融合召唤「召唤兽」怪兽
	local res1=Duel.IsExistingMatchingCard(s.fspfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res1 then
		-- 获取玩家生效中的连锁物质（Chain Material）效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg5=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用连锁物质素材再次检查分支1融合召唤可行性
			res1=Duel.IsExistingMatchingCard(s.fspfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg5,mf,chkf)
		end
	end
	-- 检查分支2（自己场地+对方场地素材）是否能融合召唤「召唤兽」怪兽
	local res2=Duel.IsExistingMatchingCard(s.fspfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,nil,chkf)
	if not res2 then
		-- 获取玩家生效中的连锁物质（Chain Material）效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg6=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用连锁物质素材再次检查分支2融合召唤可行性
			res2=Duel.IsExistingMatchingCard(s.fspfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg6,mf,chkf)
		end
	end
	if chk==0 then return res1 or res2 end
	-- 让玩家选择要适用的效果分支
	local op=aux.SelectFromOptions(tp,
			{res1,aux.Stringid(id,1),1},
			{res2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：根据选择的分支收集素材并除外，融合召唤「召唤兽」融合怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Group.CreateGroup()
	local sg1=Group.CreateGroup()
	if e:GetLabel()==1 then
		-- 分支1：获取自己手卡·场地的可用融合素材
		mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter1,nil,e)
		-- 分支1：获取自己卡组的可用融合素材
		local mg2=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 分支1：筛选额外卡组中可融合召唤的「召唤兽」怪兽
		sg1=Duel.GetMatchingGroup(s.fspfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	elseif e:GetLabel()==2 then
		-- 分支2：获取自己场地的可用融合素材
		mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter2,nil,e)
		-- 分支2：获取对方场地的可用融合素材
		local mg2=Duel.GetMatchingGroup(s.cmfilter,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		-- 分支2：筛选额外卡组中可融合召唤的「召唤兽」怪兽
		sg1=Duel.GetMatchingGroup(s.fspfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	end
	local mg2=nil
	local sg2=nil
	-- 检查是否存在连锁物质效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		if e:GetLabel()==1 then
			-- 分支1：筛选适用连锁物质时可融合召唤的怪兽
			sg2=Duel.GetMatchingGroup(s.fspfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		elseif e:GetLabel()==2 then
			-- 分支2：筛选适用连锁物质时可融合召唤的怪兽
			sg2=Duel.GetMatchingGroup(s.fspfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要融合召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规素材方式进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if e:GetLabel()==1 then
				-- 分支1：设置素材位置检查（手卡/场地1张+卡组1张）
				aux.FCheckAdditional=s.fcheck1
			elseif e:GetLabel()==2 then
				-- 分支2：设置素材控制者检查（自己场地1张+对方场地1张）
				aux.FCheckAdditional=s.fcheck2
			end
			-- 让玩家选择用于融合召唤的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 重置素材检查回调
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选中的融合素材表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 连接效果块（分隔素材除外与特召怪兽的操作）
			Duel.BreakEffect()
			-- 将选中的融合怪兽进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 适用连锁物质效果时选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
