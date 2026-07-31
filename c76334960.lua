--召喚魔術－「杯」
local s,id,o=GetID()
-- 初始化卡片效果：注册卡片发动效果，提供从手牌·场上·卡组除外素材或双方场上除外素材融合召唤「召唤兽」融合怪兽的分支选项
function s.initial_effect(c)
	-- ①：自己场上·墓地·除外状态有「阿莱斯特」怪兽存在的场合才能发动。从以下效果选择1个发动。
●从自己的手卡·场上·卡组把融合怪兽卡决定的融合素材怪兽表侧表示除外，把1只「召唤兽」融合怪兽从额外卡组融合召唤。这个效果选择的融合素材包含卡组的怪兽的场合，只能是手卡·场上1只和卡组1只。
●从自己及对方场上把融合怪兽卡决定的融合素材怪兽表侧表示除外，把1只「召唤兽」融合怪兽从额外卡组融合召唤。这个效果选择的融合素材只能是自己场上1只和对方场上1只。
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
-- 发动条件过滤：场上、墓地或除外区表侧表示的「阿莱斯特」卡
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1e1)
end
-- ①效果发动条件：自己场上·墓地·除外状态存在表侧表示的「阿莱斯特」怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上、墓地或除外区是否存在「阿莱斯特」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
-- 模式1手牌/场上素材过滤：不受效果影响且可以除外
function s.fmfilter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsAbleToRemove()
end
-- 模式2己方场上素材过滤：场上的怪兽、不受效果影响且可以除外
function s.fmfilter2(c,e)
	return c:IsLocation(LOCATION_MZONE) and not c:IsImmuneToEffect(e)
		and c:IsAbleToRemove()
end
-- 模式1卡组素材过滤：卡组中的怪兽、可以作为融合素材且可以除外
function s.dmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 模式2对方场上素材过滤：对方场上表侧表示怪兽、可以作为融合素材、可以除外且不受效果影响
function s.cmfilter(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
		and not c:IsImmuneToEffect(e)
end
-- 模式1融合怪兽筛选：额外卡组的「召唤兽」融合怪兽，且满足模式1（手牌/场上1只+卡组1只）素材组合规则
function s.fspfilter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置模式1附加融合素材检查函数
	aux.FCheckAdditional=s.fcheck1
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 重置附加融合素材检查函数
	aux.FCheckAdditional=nil
	return res
end
-- 模式2融合怪兽筛选：额外卡组的「召唤兽」融合怪兽，且满足模式2（自己场上1只+对方场上1只）素材组合规则
function s.fspfilter2(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置模式2附加融合素材检查函数
	aux.FCheckAdditional=s.fcheck2
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 重置附加融合素材检查函数
	aux.FCheckAdditional=nil
	return res
end
-- 模式1素材组合规则：必须包含1张手牌/场上素材与1张卡组素材
function s.fcheck1(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD)==1
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==1
end
-- 模式2素材组合规则：必须包含1张自己场上素材与1张对方场上素材
function s.fcheck2(tp,sg,fc)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
		and sg:FilterCount(Card.IsControler,nil,1-tp)==1
end
-- ①效果发动准备：检查两种模式的可行性，让玩家选择效果分支并设置融合特召操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取自己手卡与场上可用于模式1的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter1,nil,e)
	-- 获取自己卡组中可用于模式1的融合素材
	local mg2=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 获取自己场上可用于模式2的融合素材
	local mg3=Duel.GetFusionMaterial(tp):Filter(s.fmfilter2,nil,e)
	-- 获取对方场上可用于模式2的融合素材
	local mg4=Duel.GetMatchingGroup(s.cmfilter,tp,0,LOCATION_MZONE,nil,e)
	mg3:Merge(mg4)
	-- 检查额外卡组是否存在满足模式1素材规则可融合召唤的「召唤兽」怪兽
	local res1=Duel.IsExistingMatchingCard(s.fspfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res1 then
		-- 获取玩家生效的连锁素材效果（如「连锁素材」）
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg5=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用连锁素材提供的素材重新检查模式1可行性
			res1=Duel.IsExistingMatchingCard(s.fspfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg5,mf,chkf)
		end
	end
	-- 检查额外卡组是否存在满足模式2素材规则可融合召唤的「召唤兽」怪兽
	local res2=Duel.IsExistingMatchingCard(s.fspfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,nil,chkf)
	if not res2 then
		-- 获取玩家生效的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg6=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用连锁素材提供的素材重新检查模式2可行性
			res2=Duel.IsExistingMatchingCard(s.fspfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg6,mf,chkf)
		end
	end
	if chk==0 then return res1 or res2 end
	-- 提示玩家在可行的分支中选择发动其中1个效果模式
	local op=aux.SelectFromOptions(tp,
			{res1,aux.Stringid(id,1),1},
			{res2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：根据选定的模式选择素材并表侧表示除外，从额外卡组融合召唤「召唤兽」融合怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Group.CreateGroup()
	local sg1=Group.CreateGroup()
	if e:GetLabel()==1 then
		-- 模式1分支：搜集手卡与场上的合法素材
		mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter1,nil,e)
		-- 模式1分支：搜集卡组中的合法素材
		local mg2=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 模式1分支：筛选可融合召唤的「召唤兽」怪兽组
		sg1=Duel.GetMatchingGroup(s.fspfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	elseif e:GetLabel()==2 then
		-- 模式2分支：搜集自己场上的合法素材
		mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter2,nil,e)
		-- 模式2分支：搜集对方场上的合法素材
		local mg2=Duel.GetMatchingGroup(s.cmfilter,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		-- 模式2分支：筛选可融合召唤的「召唤兽」怪兽组
		sg1=Duel.GetMatchingGroup(s.fspfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	end
	local mg2=nil
	local sg2=nil
	-- 检查是否存在连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		if e:GetLabel()==1 then
			-- 使用连锁素材计算模式1可融合召唤的怪兽
			sg2=Duel.GetMatchingGroup(s.fspfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		elseif e:GetLabel()==2 then
			-- 使用连锁素材计算模式2可融合召唤的怪兽
			sg2=Duel.GetMatchingGroup(s.fspfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if e:GetLabel()==1 then
				-- 应用模式1的附加融合素材校验函数
				aux.FCheckAdditional=s.fcheck1
			elseif e:GetLabel()==2 then
				-- 应用模式2的附加融合素材校验函数
				aux.FCheckAdditional=s.fcheck2
			end
			-- 提示玩家选择满足对应模式规则的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除附加融合素材校验函数
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选中的融合素材表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 连接效果块（分隔素材除外与融合特召）
			Duel.BreakEffect()
			-- 将选中的「召唤兽」融合怪兽以融合召唤手续表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材效果选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
