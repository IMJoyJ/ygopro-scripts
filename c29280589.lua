--エッジインプ・サイズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方主要阶段，把手卡的这张卡给对方观看才能发动。从自己的手卡·场上把「魔玩具」融合怪兽卡决定的包含手卡的这张卡的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：自己场上的「魔玩具」融合怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c29280589.initial_effect(c)
	-- 效果原文内容：①：对方主要阶段，把手卡的这张卡给对方观看才能发动。从自己的手卡·场上把「魔玩具」融合怪兽卡决定的包含手卡的这张卡的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29280589,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,29280589)
	e1:SetCondition(c29280589.condition)
	e1:SetCost(c29280589.cost)
	e1:SetTarget(c29280589.target)
	e1:SetOperation(c29280589.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己场上的「魔玩具」融合怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29280590)
	e2:SetTarget(c29280589.reptg)
	e2:SetValue(c29280589.repval)
	c:RegisterEffect(e2)
end
-- 效果作用：判断是否为对方主要阶段
function c29280589.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否为对方主要阶段
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and Duel.GetTurnPlayer()==1-tp
end
-- 效果作用：检查手卡是否公开
function c29280589.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果作用：过滤函数，用于判断卡是否免疫效果
function c29280589.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 效果作用：过滤函数，用于筛选满足融合召唤条件的「魔玩具」融合怪兽
function c29280589.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xad) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 效果作用：设置融合召唤效果的发动条件和目标
function c29280589.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 效果作用：获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 效果作用：检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c29280589.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 效果作用：获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 效果作用：检查是否存在满足连锁融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c29280589.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 效果作用：设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：执行融合召唤效果的处理流程
function c29280589.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 效果作用：过滤融合素材中未被免疫的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c29280589.filter1,nil,e)
	-- 效果作用：获取满足融合召唤条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c29280589.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果作用：获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果作用：获取满足连锁融合素材条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c29280589.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 效果作用：提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 效果作用：判断是否使用普通融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 效果作用：选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 效果作用：将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 效果作用：选择连锁融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 效果作用：过滤函数，用于判断是否为「魔玩具」融合怪兽
function c29280589.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0xad)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 效果作用：设置代替破坏的效果处理
function c29280589.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c29280589.repfilter,1,nil,tp) end
	-- 效果作用：询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 效果作用：将此卡除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 效果作用：返回代替破坏的判断结果
function c29280589.repval(e,c)
	return c29280589.repfilter(c,e:GetHandlerPlayer())
end
