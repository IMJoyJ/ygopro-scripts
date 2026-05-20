--魔神王の契約書
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。「DD」融合怪兽融合召唤的场合，也能把自己墓地的怪兽除外作为融合素材。
-- ②：自己准备阶段发动。自己受到1000伤害。
function c73360025.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。「DD」融合怪兽融合召唤的场合，也能把自己墓地的怪兽除外作为融合素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73360025,0))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,73360025)
	e2:SetTarget(c73360025.sptg)
	e2:SetOperation(c73360025.spop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c73360025.damcon)
	e3:SetTarget(c73360025.damtg)
	e3:SetOperation(c73360025.damop)
	c:RegisterEffect(e3)
end
-- 过滤墓地中可以作为融合素材且可以除外的怪兽
function c73360025.mfilter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤不受当前效果影响的怪兽
function c73360025.mfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤墓地中可以作为融合素材、可以除外且不受当前效果影响的怪兽
function c73360025.mfilter2(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以使用指定素材进行融合召唤的恶魔族融合怪兽
function c73360025.spfilter1(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤额外卡组中可以使用指定素材进行融合召唤的「DD」恶魔族融合怪兽
function c73360025.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and c:IsSetCard(0xaf) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与可行性检查
function c73360025.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上的可用融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在仅用手卡·场上素材即可融合召唤的恶魔族融合怪兽
		local res=Duel.IsExistingMatchingCard(c73360025.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if res then return true end
		-- 获取玩家墓地中可以作为融合素材且可以除外的怪兽
		local mg2=Duel.GetMatchingGroup(c73360025.mfilter0,tp,LOCATION_GRAVE,0,nil)
		mg2:Merge(mg1)
		-- 检查额外卡组是否存在可以使用手卡·场上·墓地素材融合召唤的「DD」恶魔族融合怪兽
		res=Duel.IsExistingMatchingCard(c73360025.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下是否存在可融合召唤的恶魔族融合怪兽
				res=Duel.IsExistingMatchingCard(c73360025.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的执行处理
function c73360025.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取手卡·场上不受此效果影响以外的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c73360025.mfilter1,nil,e)
	-- 获取仅用手卡·场上素材可融合召唤的恶魔族融合怪兽组
	local sg1=Duel.GetMatchingGroup(c73360025.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 获取墓地中可除外且不受此效果影响的可用融合素材
	local mg2=Duel.GetMatchingGroup(c73360025.mfilter2,tp,LOCATION_GRAVE,0,nil,e)
	mg2:Merge(mg1)
	-- 获取可使用手卡·场上·墓地素材融合召唤的「DD」恶魔族融合怪兽组
	local sg2=Duel.GetMatchingGroup(c73360025.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,nil,chkf)
	sg1:Merge(sg2)
	local mg3=nil
	local sg3=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可融合召唤的恶魔族融合怪兽组
		sg3=Duel.GetMatchingGroup(c73360025.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg3~=nil and sg3:GetCount()>0) then
		local sg=sg1:Clone()
		if sg3 then sg:Merge(sg3) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（而非连锁素材等其他效果）
		if sg1:IsContains(tc) and (sg3==nil or not sg3:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if tc:IsSetCard(0xaf) then
				-- 让玩家从手卡·场上·墓地中选择融合召唤「DD」融合怪兽所需的融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				tc:SetMaterial(mat1)
				local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
				mat1:Sub(mat2)
				-- 将手卡·场上的融合素材送去墓地
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 将墓地的融合素材除外
				Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			else
				-- 让玩家从手卡·场上选择融合召唤非「DD」恶魔族融合怪兽所需的融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat2)
				-- 将选中的融合素材送去墓地
				Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			end
			-- 中断当前效果，使之后的特殊召唤处理与送墓/除外处理不视为同时进行
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果影响下，让玩家选择融合召唤所需的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
	end
end
-- 准备阶段伤害效果的发动条件函数
function c73360025.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段伤害效果的目标确认与操作信息设置
function c73360025.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置受到伤害的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置伤害数值为1000
	Duel.SetTargetParam(1000)
	-- 设置当前处理的操作信息为给与玩家1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 准备阶段伤害效果的执行处理
function c73360025.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 依效果给与目标玩家伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
