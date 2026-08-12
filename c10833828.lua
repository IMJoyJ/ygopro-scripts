--魔神王の禁断契約書
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只「DDD」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：1回合1次，自己主要阶段才能发动。包含用这张卡的①的效果特殊召唤的怪兽的自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。
-- ③：自己准备阶段发动。自己受到2000伤害。
function c10833828.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只「DDD」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10833828,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c10833828.sptg1)
	e2:SetOperation(c10833828.spop1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。包含用这张卡的①的效果特殊召唤的怪兽的自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10833828,1))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c10833828.sptg2)
	e3:SetOperation(c10833828.spop2)
	c:RegisterEffect(e3)
	-- ③：自己准备阶段发动。自己受到2000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10833828,2))  --"效果伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c10833828.damcon)
	e4:SetTarget(c10833828.damtg)
	e4:SetOperation(c10833828.damop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选手卡中可以特殊召唤的DDD怪兽
function c10833828.spfilter1(c,e,tp)
	return c:IsSetCard(0x10af) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动时点处理函数，检查是否满足发动条件
function c10833828.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的DDD怪兽
		and Duel.IsExistingMatchingCard(c10833828.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时要操作的卡片信息，包括特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 向对方玩家提示发动了效果①
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的处理函数，执行特殊召唤并使召唤的怪兽效果无效
function c10833828.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手卡中选择一只满足条件的DDD怪兽
	local g=Duel.SelectMatchingCard(tp,c10833828.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功特殊召唤，则为该怪兽设置效果使其效果无效
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 为特殊召唤的怪兽设置效果使其无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 为特殊召唤的怪兽设置效果使其效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(10833828,RESET_EVENT+RESETS_STANDARD,0,1,c:GetFieldID())
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 过滤函数，用于筛选不受效果影响的怪兽
function c10833828.spfilter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选可以作为融合召唤素材的恶魔族融合怪兽
function c10833828.spfilter3(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 创建一个用于检查融合素材是否包含特定怪兽的函数
function c10833828.fcheck1(fid)
	return	function(tp,sg,fc)
				return sg:IsExists(c10833828.fcheck2,1,nil,fid)
			end
end
-- 检查指定怪兽是否包含特定flag
function c10833828.fcheck2(c,fid)
	for _,flag in ipairs({c:GetFlagEffectLabel(10833828)}) do
		if flag==fid then return true end
	end
	return false
end
-- 效果②的发动时点处理函数，检查是否满足发动条件
function c10833828.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 设置融合素材检查附加条件
		aux.FCheckAdditional=c10833828.fcheck1(e:GetHandler():GetFieldID())
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c10833828.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c10833828.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清除融合素材检查附加条件
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置效果处理时要操作的卡片信息，包括融合召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家提示发动了效果②
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的处理函数，执行融合召唤
function c10833828.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取玩家当前可用的融合素材并过滤掉免疫效果的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c10833828.spfilter2,nil,e)
	-- 设置融合素材检查附加条件
	aux.FCheckAdditional=c10833828.fcheck1(c:GetFieldID())
	-- 获取满足条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c10833828.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c10833828.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示选择要融合召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果
			Duel.BreakEffect()
			-- 执行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除融合素材检查附加条件
	aux.FCheckAdditional=nil
end
-- 效果③的触发条件函数，判断是否为自己的准备阶段
function c10833828.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段
	return Duel.GetTurnPlayer()==tp
end
-- 效果③的发动时点处理函数，设置要处理的伤害信息
function c10833828.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置要受到伤害的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置要受到的伤害值
	Duel.SetTargetParam(2000)
	-- 设置效果处理时要操作的卡片信息，包括伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,2000)
end
-- 效果③的处理函数，执行伤害处理
function c10833828.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
