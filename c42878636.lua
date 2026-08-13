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
-- 效果①的发动条件判定：满足发动时点后，将伤害对象玩家设定为对方，伤害数值设定为600，并登记造成600点伤害的操作信息。
function c42878636.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本效果的伤害对象玩家设定为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将本效果的伤害数值参数设定为600。
	Duel.SetTargetParam(600)
	-- 登记当前连锁的操作信息：将对对方玩家造成600点效果伤害，用于伤害相关效果的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果①的伤害处理：从当前连锁信息中取得之前设定的对象玩家和伤害数值，并实际给该玩家造成效果伤害。
function c42878636.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家p（伤害对象）和对象参数d（伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）给玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判定要发动的效果是否为魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），若是则该效果被禁止发动。
function c42878636.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果②的发动条件：当前攻击宣言的怪兽必须是这张卡自身。
function c42878636.actcon(e)
	-- 返回当前攻击怪兽是否等于这张卡（效果持有者）。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 融合素材过滤器：排除对此效果有免疫能力的卡。
function c42878636.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽候选过滤器：从额外卡组中筛选出属于「古代的机械」系列、能被融合召唤、且可用给定素材满足融合素材条件的融合怪兽。
function c42878636.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x7) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果③的发动条件检查：确认额外卡组中是否存在能用自己手卡·场上怪兽（或连锁素材效果提供的素材）作为融合素材的「古代的机械」融合怪兽；满足时登记从额外卡组特殊召唤1只怪兽的操作信息。
function c42878636.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得tp方可作为融合素材的卡组（手卡·场上的怪兽以及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在至少1只可以使用普通素材mg1作为融合素材的「古代的机械」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c42878636.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得tp方当前适用的连锁素材效果（如融合代替素材效果），用于扩展融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 当普通素材无法融合时，改用连锁素材效果提供的替代素材再次检查额外卡组中是否存在可融合召唤的「古代的机械」融合怪兽。
				res=Duel.IsExistingMatchingCard(c42878636.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次连锁将从额外卡组特殊召唤1只怪兽（融合召唤）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的融合召唤处理：获取普通素材和连锁素材，筛选可选融合怪兽，让玩家选择要融合召唤的怪兽及对应素材，将素材送去墓地后以融合召唤方式特殊召唤该怪兽。
function c42878636.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得tp方可用的普通融合素材，并过滤掉不受此效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c42878636.spfilter1,nil,e)
	-- 使用普通融合素材筛选出所有可融合召唤的「古代的机械」融合怪兽。
	local sg1=Duel.GetMatchingGroup(c42878636.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 取得tp方可用的连锁素材效果（如有）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材效果提供的替代素材筛选出所有可融合召唤的「古代的机械」融合怪兽。
		sg2=Duel.GetMatchingGroup(c42878636.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向tp方发送“请选择要特殊召唤的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否属于普通素材候选，且在不存在连锁素材候选或玩家选择不使用连锁素材效果时，走普通素材融合流程；否则走连锁素材效果融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组中选择用于融合召唤的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以效果·素材·融合的原因送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤处理与素材送墓不在同一时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将选择的融合怪兽特殊召唤到tp方场上（表侧攻击表示）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材效果时，让玩家从替代素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
