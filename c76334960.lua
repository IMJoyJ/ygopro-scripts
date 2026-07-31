--召喚魔術－「杯」
local s,id,o=GetID()
-- 初始化卡片效果：注册作为卡片发动的融合召唤效果（誓约同名卡1回合1次）
function s.initial_effect(c)
	-- 此卡名的卡在1回合只能发动1张。自己场上·墓地·除外状态有「召唤师」怪兽存在的场合才能发动。从以下效果选择1个发动。
●从手牌·场上以及自己卡组各把1只怪兽除外作为融合素材，把1只「召唤兽」融合怪兽融合召唤。
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
-- 发动前提过滤条件：表侧表示/墓地/除外状态的「召唤师」怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1e1)
end
-- 卡片发动条件检查：自己场上·墓地·除外状态存在「召唤师」怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上、墓地或除外状态是否存在符合条件的「召唤师」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
-- 分支1手牌/场上融合素材过滤条件：不受效果影响且可除外
function s.fmfilter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsAbleToRemove()
end
-- 分支2自己场上融合素材过滤条件：位于怪兽区域、不受效果影响且可除外
function s.fmfilter2(c,e)
	return c:IsLocation(LOCATION_MZONE) and not c:IsImmuneToEffect(e)
		and c:IsAbleToRemove()
end
-- 分支1卡组融合素材过滤条件：卡组中可作为融合素材且可除外的怪兽
function s.dmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 分支2对方场上融合素材过滤条件：对方场上表侧表示、可作为融合素材且可除外的怪兽
function s.cmfilter(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
		and not c:IsImmuneToEffect(e)
end
-- 分支1融合召唤目标检查：额外卡组可融合特召的「召唤兽」怪兽（需满足分支1素材限制）
function s.fspfilter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 临时设置分支1附加素材检查函数
	aux.FCheckAdditional=s.fcheck1
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除附加素材检查函数
	aux.FCheckAdditional=nil
	return res
end
-- 分支2融合召唤目标检查：额外卡组可融合特召的「召唤兽」怪兽（需满足分支2素材限制）
function s.fspfilter2(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 临时设置分支2附加素材检查函数
	aux.FCheckAdditional=s.fcheck2
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除附加素材检查函数
	aux.FCheckAdditional=nil
	return res
end
-- 分支1素材组合限制：手牌/场地恰好1张且卡组恰好1张
function s.fcheck1(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD)==1
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==1
end
-- 分支2素材组合限制：自己场上恰好1张且对方场上恰好1张
function s.fcheck2(tp,sg,fc)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
		and sg:FilterCount(Card.IsControler,nil,1-tp)==1
end
-- 卡片发动准备：检查两个分支的可行性并由玩家选择发动分支
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 收集分支1从手牌·场上的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter1,nil,e)
	-- 收集分支1从卡组的融合素材
	local mg2=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 收集分支2从自己场上的融合素材
	local mg3=Duel.GetFusionMaterial(tp):Filter(s.fmfilter2,nil,e)
	-- 收集分支2从对方场上的融合素材
	local mg4=Duel.GetMatchingGroup(s.cmfilter,tp,0,LOCATION_MZONE,nil,e)
	mg3:Merge(mg4)
	-- 检查分支1是否满足融合召唤条件
	local res1=Duel.IsExistingMatchingCard(s.fspfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res1 then
		-- 检查是否存在连锁素材替代效果（如连锁素材）
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg5=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用替代素材检查分支1是否满足融合条件
			res1=Duel.IsExistingMatchingCard(s.fspfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg5,mf,chkf)
		end
	end
	-- 检查分支2是否满足融合召唤条件
	local res2=Duel.IsExistingMatchingCard(s.fspfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,nil,chkf)
	if not res2 then
		-- 再次检查是否存在连锁素材替代效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg6=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用替代素材检查分支2是否满足融合条件
			res2=Duel.IsExistingMatchingCard(s.fspfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg6,mf,chkf)
		end
	end
	if chk==0 then return res1 or res2 end
	-- 供玩家在可行的效果分支中进行选择并记录选择结果
	local op=aux.SelectFromOptions(tp,
			{res1,aux.Stringid(id,1),1},
			{res2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 卡片发动处理：根据所选分支从对应区域除外素材并融合召唤「召唤兽」怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Group.CreateGroup()
	local sg1=Group.CreateGroup()
	if e:GetLabel()==1 then
		-- 处理分支1：重新获取手牌与场上的可用融合素材
		mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter1,nil,e)
		-- 处理分支1：重新获取卡组的可用融合素材
		local mg2=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 处理分支1：获取可融合召唤的「召唤兽」怪兽集合
		sg1=Duel.GetMatchingGroup(s.fspfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	elseif e:GetLabel()==2 then
		-- 处理分支2：重新获取自己场上的可用融合素材
		mg1=Duel.GetFusionMaterial(tp):Filter(s.fmfilter2,nil,e)
		-- 处理分支2：重新获取对方场上的可用融合素材
		local mg2=Duel.GetMatchingGroup(s.cmfilter,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		-- 处理分支2：获取可融合召唤的「召唤兽」怪兽集合
		sg1=Duel.GetMatchingGroup(s.fspfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	end
	local mg2=nil
	local sg2=nil
	-- 效果处理中检查是否存在连锁素材替代效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		if e:GetLabel()==1 then
			-- 分支1：使用替代素材获取可融合召唤的怪兽集合
			sg2=Duel.GetMatchingGroup(s.fspfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		elseif e:GetLabel()==2 then
			-- 分支2：使用替代素材获取可融合召唤的怪兽集合
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
		-- 判断是否使用常规融合素材进行召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if e:GetLabel()==1 then
				-- 设置分支1素材组合限制条件
				aux.FCheckAdditional=s.fcheck1
			elseif e:GetLabel()==2 then
				-- 设置分支2素材组合限制条件
				aux.FCheckAdditional=s.fcheck2
			end
			-- 选择满足所选分支限制条件的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 恢复默认素材检查设置
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选择的融合素材表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 分隔除外素材与特殊召唤的效果处理
			Duel.BreakEffect()
			-- 将融合怪兽融合召唤特殊召唤到场地
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
