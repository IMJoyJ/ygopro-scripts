--召喚魔術－「杯」
local s,id,o=GetID()
-- 初始化效果：注册融合召唤效果
function s.initial_effect(c)
●从手牌·场上以及自己卡组各把1只怪兽除外作为融合素材，把1只「召唤兽」融合怪兽融合召唤。
●从自己场上以及对方场上各把1只表侧表示怪兽除外作为融合素材，把1只「召唤兽」融合怪兽融合召唤。
	-- ●从手牌·场上以及自己卡组各把1只怪兽除外作为融合素材，把1只「召唤兽」融合怪兽融合召唤。
●从自己场上以及对方场上各把1只表侧表示怪兽除外作为融合素材，把1只「召唤兽」融合怪兽融合召唤。
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
-- 过滤条件：场上、墓地或除外区表侧表示的「召唤兽」怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1e1)
end
-- 判断场上、墓地或除外区是否存在「召唤兽」怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 存在至少1只满足过滤条件的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
-- 过滤条件（手牌/场上）：不受效果免疫且可以被除外的怪兽
function s.fmfilter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsAbleToRemove()
end
-- 过滤条件（自己场上）：场上不受效果免疫且可以被除外的怪兽
function s.fmfilter2(c,e)
	return c:IsLocation(LOCATION_MZONE) and not c:IsImmuneToEffect(e)
		and c:IsAbleToRemove()
end
-- 过滤条件（卡组）：卡组中可以作为融合素材并被除外的怪兽
function s.dmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤条件（对方场上）：对方场上表侧表示、不受效果免疫且可以作为融合素材并被除外的怪兽
function s.cmfilter(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
		and not c:IsImmuneToEffect(e)
end
-- 第一种融合召唤的判断：指定的融合怪兽能否特殊召唤
function s.fspfilter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置额外的融合素材检查条件（第一种）
	aux.FCheckAdditional=s.fcheck1
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除额外的检查条件
	aux.FCheckAdditional=nil
	return res
end
-- 第二种融合召唤的判断：指定的融合怪兽能否特殊召唤
function s.fspfilter2(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置额外的融合素材检查条件（第二种）
	aux.FCheckAdditional=s.fcheck2
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除额外的检查条件
	aux.FCheckAdditional=nil
	return res
end
-- 额外的检查条件（第一种）：素材必须恰好是1只手牌/场上怪兽和1只卡组怪兽
function s.fcheck1(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD)==1
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==1
end
-- 额外的检查条件（第二种）：素材必须恰好是1只自己场上的怪兽和1只对方场上的怪兽
function s.fcheck2(tp,sg,fc)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
		and sg:FilterCount(Card.IsControler,nil,1-tp)==1
end
-- 效果发动条件及操作信息设置：判断是否可以适用融合召唤并记录选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取自己手牌/场上的融合素材并过滤
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter1,nil,e)
	-- 获取卡组中可以作为融合素材的怪兽
	local mg2=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 获取自己场上的融合素材并过滤
	local mg3=Duel.GetFusionMaterial(tp):Filter(s.fmfilter2,nil,e)
	-- 获取对方场上可以作为融合素材的表侧表示怪兽
	local mg4=Duel.GetMatchingGroup(s.cmfilter,tp,0,LOCATION_MZONE,nil,e)
	mg3:Merge(mg4)
	-- 判断额外卡组是否存在可以适用第一种融合的「召唤兽」怪兽
	local res1=Duel.IsExistingMatchingCard(s.fspfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res1 then
		-- 获取连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg5=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用连锁素材判断是否存在可以适用第一种融合的怪兽
			res1=Duel.IsExistingMatchingCard(s.fspfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg5,mf,chkf)
		end
	end
	-- 判断额外卡组是否存在可以适用第二种融合的「召唤兽」怪兽
	local res2=Duel.IsExistingMatchingCard(s.fspfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,nil,chkf)
	if not res2 then
		-- 获取连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg6=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用连锁素材判断是否存在可以适用第二种融合的怪兽
			res2=Duel.IsExistingMatchingCard(s.fspfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg6,mf,chkf)
		end
	end
	if chk==0 then return res1 or res2 end
	-- 让玩家在可用的融合召唤选项中进行选择
	local op=aux.SelectFromOptions(tp,
			{res1,aux.Stringid(id,1),1},
			{res2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	-- 设置操作信息：包含特殊召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤的操作处理：选择融合怪兽，除外融合素材，并融合召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Group.CreateGroup()
	local sg1=Group.CreateGroup()
	if e:GetLabel()==1 then
		-- 根据第一种选项，获取自己手牌/场上的融合素材并过滤
		mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter1,nil,e)
		-- 获取卡组中可以作为融合素材的怪兽
		local mg2=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 获取可以进行第一种融合召唤的融合怪兽集合
		sg1=Duel.GetMatchingGroup(s.fspfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	elseif e:GetLabel()==2 then
		-- 根据第二种选项，获取自己场上的融合素材并过滤
		mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter2,nil,e)
		-- 获取对方场上可以作为融合素材的表侧表示怪兽
		local mg2=Duel.GetMatchingGroup(s.cmfilter,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		-- 获取可以进行第二种融合召唤的融合怪兽集合
		sg1=Duel.GetMatchingGroup(s.fspfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	end
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		if e:GetLabel()==1 then
			-- 获取适用连锁素材可以进行第一种融合召唤的融合怪兽集合
			sg2=Duel.GetMatchingGroup(s.fspfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		elseif e:GetLabel()==2 then
			-- 获取适用连锁素材可以进行第二种融合召唤的融合怪兽集合
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
		-- 判断玩家是否选择不使用连锁素材进行融合
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if e:GetLabel()==1 then
				-- 设置第一种融合的额外素材检查条件
				aux.FCheckAdditional=s.fcheck1
			elseif e:GetLabel()==2 then
				-- 设置第二种融合的额外素材检查条件
				aux.FCheckAdditional=s.fcheck2
			end
			-- 让玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除额外的检查条件
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选定的融合素材除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理时点
			Duel.BreakEffect()
			-- 将选择的融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 适用连锁素材处理时让玩家选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
