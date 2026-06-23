--古代の機械猟犬
-- 效果：
-- ①：这张卡召唤的场合发动。给与对方600伤害。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ③：1回合1次，自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「古代的机械」融合怪兽融合召唤。
function c42878636.initial_effect(c)
	-- ①：这张卡召唤的场合发动。给与对方600伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42878636,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c42878636.damtg)
	e1:SetOperation(c42878636.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c42878636.aclimit)
	e2:SetCondition(c42878636.actcon)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「古代的机械」融合怪兽融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42878636,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c42878636.sptg)
	e3:SetOperation(c42878636.spop)
	c:RegisterEffect(e3)
end
-- 设置伤害效果的处理目标为对方玩家
function c42878636.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的处理参数为600
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的操作信息为对对方造成600点伤害
	Duel.SetTargetParam(600)
	-- 执行对对方造成600点伤害的效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 获取连锁中伤害效果的目标玩家和参数值
function c42878636.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对目标玩家造成指定伤害值的效果
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 判断效果是否为魔法·陷阱卡的发动
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断攻击怪兽是否为本卡
function c42878636.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断攻击怪兽是否为本卡
function c42878636.actcon(e)
	-- 判断攻击怪兽是否为本卡
	return Duel.GetAttacker()==e:GetHandler()
end
-- 过滤函数，检查卡是否免疫效果
function c42878636.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，检查卡是否为融合怪兽且属于古代的机械族
function c42878636.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x7) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 设置融合召唤效果的处理目标为从额外卡组特殊召唤
function c42878636.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c42878636.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c42878636.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置融合召唤效果的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理融合召唤效果的执行逻辑
function c42878636.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 过滤融合素材中不免疫效果的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c42878636.spfilter1,nil,e)
	-- 获取满足融合召唤条件的额外卡组怪兽
	local sg1=Duel.GetMatchingGroup(c42878636.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足融合召唤条件的额外卡组怪兽
		sg2=Duel.GetMatchingGroup(c42878636.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材效果进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
