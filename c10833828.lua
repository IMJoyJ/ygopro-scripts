--魔神王の禁断契約書
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只「DDD」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：1回合1次，自己主要阶段才能发动。包含用这张卡的①的效果特殊召唤的怪兽的自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。
-- ③：自己准备阶段发动。自己受到2000伤害。
function c10833828.initial_effect(c)
	-- 效果原文内容：①：1回合1次，自己主要阶段才能发动。从手卡把1只「DDD」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：1回合1次，自己主要阶段才能发动。包含用这张卡的①的效果特殊召唤的怪兽的自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10833828,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c10833828.sptg1)
	e2:SetOperation(c10833828.spop1)
	c:RegisterEffect(e2)
	-- 效果原文内容：③：自己准备阶段发动。自己受到2000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10833828,1))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c10833828.sptg2)
	e3:SetOperation(c10833828.spop2)
	c:RegisterEffect(e3)
	-- 效果作用：设置卡牌的激活效果，使其在自由连锁时可以发动
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
-- 效果作用：定义用于筛选手卡中「DDD」怪兽的过滤函数
function c10833828.spfilter1(c,e,tp)
	return c:IsSetCard(0x10af) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：定义①效果的发动条件判断函数
function c10833828.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查玩家手卡中是否存在满足条件的「DDD」怪兽
		and Duel.IsExistingMatchingCard(c10833828.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 效果作用：向对手提示当前效果已被选择
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果作用：定义①效果的处理函数
function c10833828.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 效果作用：从手卡中选择一只「DDD」怪兽
	local g=Duel.SelectMatchingCard(tp,c10833828.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 效果作用：尝试特殊召唤所选怪兽并设置其效果无效
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(10833828,RESET_EVENT+RESETS_STANDARD,0,1,c:GetFieldID())
	end
	-- 效果作用：完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果作用：定义用于筛选融合素材的过滤函数
function c10833828.spfilter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 效果作用：定义用于筛选恶魔族融合怪兽的过滤函数
function c10833828.spfilter3(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果作用：定义用于检查融合素材是否包含特定怪兽的辅助函数
function c10833828.fcheck1(fid)
	return	function(tp,sg,fc)
				return sg:IsExists(c10833828.fcheck2,1,nil,fid)
			end
end
-- 效果作用：检查怪兽是否具有特定标志位
function c10833828.fcheck2(c,fid)
	for _,flag in ipairs({c:GetFlagEffectLabel(10833828)}) do
		if flag==fid then return true end
	end
	return false
end
-- 效果作用：定义②效果的发动条件判断函数
function c10833828.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 效果作用：获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 效果作用：设置融合检查附加条件
		aux.FCheckAdditional=c10833828.fcheck1(e:GetHandler():GetFieldID())
		-- 效果作用：检查是否存在满足条件的恶魔族融合怪兽
		local res=Duel.IsExistingMatchingCard(c10833828.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 效果作用：获取当前连锁的融合素材
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 效果作用：检查是否存在满足条件的恶魔族融合怪兽
				res=Duel.IsExistingMatchingCard(c10833828.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 效果作用：清除融合检查附加条件
		aux.FCheckAdditional=nil
		return res
	end
	-- 效果作用：设置连锁操作信息，表示将要融合召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 效果作用：向对手提示当前效果已被选择
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果作用：定义②效果的处理函数
function c10833828.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 效果作用：获取玩家可用的融合素材并过滤
	local mg1=Duel.GetFusionMaterial(tp):Filter(c10833828.spfilter2,nil,e)
	-- 效果作用：设置融合检查附加条件
	aux.FCheckAdditional=c10833828.fcheck1(c:GetFieldID())
	-- 效果作用：获取满足条件的恶魔族融合怪兽
	local sg1=Duel.GetMatchingGroup(c10833828.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果作用：获取当前连锁的融合素材
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果作用：获取满足条件的恶魔族融合怪兽
		sg2=Duel.GetMatchingGroup(c10833828.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 效果作用：提示玩家选择要融合召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 效果作用：判断是否使用原融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 效果作用：选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 效果作用：将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 效果作用：中断当前效果
			Duel.BreakEffect()
			-- 效果作用：进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 效果作用：选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 效果作用：清除融合检查附加条件
	aux.FCheckAdditional=nil
end
-- 效果作用：定义③效果的发动条件判断函数
function c10833828.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 效果作用：定义③效果的目标设定函数
function c10833828.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置目标玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置目标伤害值
	Duel.SetTargetParam(2000)
	-- 效果作用：设置连锁操作信息，表示将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,2000)
end
-- 效果作用：定义③效果的处理函数
function c10833828.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁信息中的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：对目标玩家造成伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
