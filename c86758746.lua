--アマゾネスの秘術
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的手卡·场上把「亚马逊」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。这个回合，自己把「亚马逊」融合怪兽融合召唤的场合只有1次，也能把自己的额外卡组1只「亚马逊」怪兽送去墓地作为融合素材。
local s,id,o=GetID()
-- 初始化卡片效果，注册手卡·场上融合召唤的效果与墓地除外提供额外卡组融合素材的效果，并重写系统融合素材相关函数以支持从额外卡组送墓素材
function s.initial_effect(c)
	-- ①：从自己的手卡·场上把「亚马逊」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。这个回合，自己把「亚马逊」融合怪兽融合召唤的场合只有1次，也能把自己的额外卡组1只「亚马逊」怪兽送去墓地作为融合素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 将墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.fusop)
	c:RegisterEffect(e2)
	-- 检查是否尚未重写过融合素材相关的系统函数
	if not aux.fus_mat_hack_check then
		-- 标记已重写融合素材相关的系统函数，防止重复执行
		aux.fus_mat_hack_check=true
		-- 过滤具有“可作为额外融合素材”效果的卡片
		function aux.fus_mat_hack_exmat_filter(c)
			return c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,c:GetControler())
		end
		-- 保存系统原有的获取融合素材函数
		_GetFusionMaterial=Duel.GetFusionMaterial
		-- 重写获取融合素材函数，使其能获取到额外卡组中符合条件的卡
		function Duel.GetFusionMaterial(tp,loc)
			if loc==nil then loc=LOCATION_HAND+LOCATION_MZONE end
			local g=_GetFusionMaterial(tp,loc)
			-- 获取自己额外卡组中受“可作为额外融合素材”效果影响的卡片组
			local exg=Duel.GetMatchingGroup(aux.fus_mat_hack_exmat_filter,tp,LOCATION_EXTRA,0,nil)
			return g+exg
		end
		-- 保存系统原有的送去墓地函数
		_SendtoGrave=Duel.SendtoGrave
		-- 重写送去墓地函数，以正确处理从额外卡组送去墓地的融合素材
		function Duel.SendtoGrave(tg,reason)
			-- 如果不是因为融合召唤效果将素材送去墓地，或者操作对象不是卡片组，则执行原送墓处理
			if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
				return _SendtoGrave(tg,reason)
			end
			-- 从目标卡片组中筛选出处于额外卡组或墓地、且具有额外融合素材效果的第一张卡片
			local tc=tg:Filter(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_GRAVE):Filter(aux.fus_mat_hack_exmat_filter,nil):GetFirst()
			if tc then
				local te=tc:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,tc:GetControler())
				te:UseCountLimit(tc:GetControler())
			end
			local rg=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			tg:Sub(rg)
			local ct1=_SendtoGrave(tg,reason)
			-- 将目标卡片组中当前处于墓地的卡片进行表侧表示除外处理
			local ct2=Duel.Remove(rg,POS_FACEUP,reason)
			return ct1+ct2
		end
	end
end
-- 过滤不受当前效果影响的卡片
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「亚马逊」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与可行性检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材卡片组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「亚马逊」融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在可以使用连锁素材效果提供的素材进行融合召唤的「亚马逊」融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁信息，表示此效果会从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理，选择融合怪兽、选择素材、送去墓地并特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取不受当前效果影响的可用融合素材卡片组
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的「亚马逊」融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取额外卡组中可以使用连锁素材效果提供的素材融合召唤的「亚马逊」融合怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若不能使用连锁素材，或玩家选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材作为融合素材因效果送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材效果提供的素材中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 墓地效果的处理，注册一个允许从额外卡组将「亚马逊」怪兽送去墓地作为融合素材的全局效果
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己把「亚马逊」融合怪兽融合召唤的场合只有1次，也能把自己的额外卡组1只「亚马逊」怪兽送去墓地作为融合素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	e1:SetCountLimit(1)
	e1:SetTarget(s.mttg)
	e1:SetValue(s.mtval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该全局效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制额外卡组中可作为融合素材的卡必须是「亚马逊」怪兽且能送去墓地
function s.mttg(e,c)
	return c:IsSetCard(0x4) and c:IsAbleToGrave()
end
-- 限制该额外融合素材效果仅适用于融合召唤「亚马逊」融合怪兽
function s.mtval(e,c)
	if not c then return true end
	return c:IsSetCard(0x4)
end
