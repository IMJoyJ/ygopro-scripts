--プレデター・プライム・フュージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上有「捕食植物」怪兽存在的场合才能发动。从自己·对方场上把暗属性融合怪兽卡决定的包含自己场上的暗属性怪兽2只以上在内的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c8148322.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：场上有「捕食植物」怪兽存在的场合才能发动。从自己·对方场上把暗属性融合怪兽卡决定的包含自己场上的暗属性怪兽2只以上在内的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,8148322+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c8148322.condition)
	e1:SetTarget(c8148322.target)
	e1:SetOperation(c8148322.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「捕食植物」怪兽
function c8148322.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10f3)
end
-- 发动条件：场上有「捕食植物」怪兽存在
function c8148322.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只表侧表示的「捕食植物」怪兽
	return Duel.IsExistingMatchingCard(c8148322.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤条件：对方场上可以作为融合素材的表侧表示怪兽
function c8148322.filter0(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
-- 过滤条件：对方场上可以作为融合素材且不受此卡效果影响的表侧表示怪兽
function c8148322.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以进行融合召唤的暗属性融合怪兽
function c8148322.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤条件：自己场上可以作为融合素材且不受此卡效果影响的怪兽
function c8148322.filter3(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：属于自己场上的融合素材
function c8148322.ffilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
-- 融合素材检查：选取的融合素材中必须包含2只或以上自己场上的怪兽
function c8148322.fcheck(tp,sg,fc)
	return sg:FilterCount(c8148322.ffilter,nil,tp)>=2
end
-- 效果发动时的目标选择与合法性检测
function c8148322.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 获取对方场上可用的融合素材
		local mg2=Duel.GetMatchingGroup(c8148322.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 设定融合素材的额外检查函数（必须包含自己场上2只以上怪兽）
		aux.FGoalCheckAdditional=c8148322.fcheck
		-- 检查额外卡组是否存在可以使用上述素材融合召唤的暗属性融合怪兽
		local res=Duel.IsExistingMatchingCard(c8148322.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 重置融合素材额外检查函数
		aux.FGoalCheckAdditional=nil
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果适用下，检查是否存在可融合召唤的暗属性融合怪兽
				res=Duel.IsExistingMatchingCard(c8148322.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：将融合素材送去墓地，并从额外卡组融合召唤
function c8148322.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己场上不受此卡效果影响的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c8148322.filter3,nil,e)
	-- 获取对方场上不受此卡效果影响的可用融合素材
	local mg2=Duel.GetMatchingGroup(c8148322.filter1,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 设定融合素材的额外检查函数（必须包含自己场上2只以上怪兽）
	aux.FGoalCheckAdditional=c8148322.fcheck
	-- 获取额外卡组中可以使用上述素材融合召唤的暗属性融合怪兽组
	local sg1=Duel.GetMatchingGroup(c8148322.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 重置融合素材额外检查函数
	aux.FGoalCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果适用下可以融合召唤的暗属性融合怪兽组
		sg2=Duel.GetMatchingGroup(c8148322.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（而非连锁素材的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 设定融合素材的额外检查函数（必须包含自己场上2只以上怪兽）
			aux.FGoalCheckAdditional=c8148322.fcheck
			-- 让玩家选择一组满足条件的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 重置融合素材额外检查函数
			aux.FGoalCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选取的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地视为同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽从额外卡组进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果适用下，让玩家选择一组融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
