--EMオッドアイズ・ディゾルヴァー
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己的灵摆怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。这张卡从手卡特殊召唤，那只自己怪兽不会被那次战斗破坏。
-- ②：自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
function c46136942.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤、灵摆卡发动等），使其作为灵摆怪兽在规则上正确运作。
	aux.EnablePendulumAttribute(c)
	-- 对应灵摆效果“①：1回合1次，自己主要阶段才能发动。从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46136942,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c46136942.pftg)
	e1:SetOperation(c46136942.pfop)
	c:RegisterEffect(e1)
	-- 对应“这个卡名的①的怪兽效果1回合只能使用1次。①：自己的灵摆怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。这张卡从手卡特殊召唤，那只自己怪兽不会被那次战斗破坏。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46136942,1))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,46136942)
	e2:SetCondition(c46136942.spcon)
	e2:SetTarget(c46136942.sptg)
	e2:SetOperation(c46136942.spop)
	c:RegisterEffect(e2)
	-- 对应“②：自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。”
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c46136942.mftg)
	e3:SetOperation(c46136942.mfop)
	c:RegisterEffect(e3)
end
-- 判断素材怪兽c是否不免疫当前效果e，用于过滤出可以作为融合素材且不会被效果无效的怪兽。
function c46136942.pffilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 判断额外卡组中的c是否为龙族融合怪兽、是否可由素材组m进行融合召唤、且能够被当前效果以融合召唤方式特殊召唤；f为连锁素材附加过滤条件，chkf用于检查融合素材的合法性。
function c46136942.pffilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 灵摆效果的发动条件判定：在发动时检查额外卡组是否存在满足条件的龙族融合怪兽；先获取常规融合素材（手卡·场上）进行检索，若不存在则再检查连锁素材效果能否提供额外素材；满足条件则允许发动，并设置特殊召唤1只额外怪兽的操作信息。
function c46136942.pftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp当前可用于融合召唤的素材组（含手卡·场上怪兽及受额外融合素材效果影响的卡），用于后续检索。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在1张龙族融合怪兽，能用当前素材组mg1进行融合召唤并被此效果特殊召唤。
		local res=Duel.IsExistingMatchingCard(c46136942.pffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家tp当前适用的连锁素材效果（EFFECT_EXTRA_FUSION_MATERIAL），用于扩展融合素材；若没有则为nil。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的素材组mg2和附加过滤条件mf，再次检查额外卡组是否存在可融合召唤的龙族融合怪兽。
				res=Duel.IsExistingMatchingCard(c46136942.pffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽，用于其他卡片效果的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果处理：从可选融合怪兽中选择1只；若该怪兽能用常规素材融合，且（无连锁素材或玩家选择不用连锁素材），则从常规素材中选择素材送去墓地，然后融合召唤；否则使用连锁素材效果进行融合；最后完成融合召唤手续。
function c46136942.pfop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取常规融合素材组，并过滤掉对当前效果免疫的卡，得到实际可用的常规素材集合mg1。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c46136942.pffilter1,nil,e)
	-- 获取额外卡组中所有可用常规素材mg1进行融合召唤且可被此效果特殊召唤的龙族融合怪兽集合sg1。
	local sg1=Duel.GetMatchingGroup(c46136942.pffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 再次获取玩家tp适用的连锁素材效果，用于扩展融合素材；若没有则为nil。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，则用连锁素材素材组mg2和过滤条件mf，获取额外卡组中可融合召唤的龙族融合怪兽集合sg2。
		sg2=Duel.GetMatchingGroup(c46136942.pffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家tp显示“请选择要特殊召唤的卡”的选择提示，用于从候选怪兽中选择融合召唤对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽tc是否能由常规素材融合；若可以且（不使用连锁素材或玩家选择不使用连锁素材），则走常规融合素材路线；否则走连锁素材路线。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规融合素材mg1中选择一组融合怪兽tc所需的融合素材（不强制额外指定卡）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材mat1送去墓地，原因是效果处理以及作为融合素材（REASON_FUSION），完成素材送入墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的融合召唤作为独立事件处理，避免错失时点。
			Duel.BreakEffect()
			-- 将融合怪兽tc以融合召唤方式表侧表示特殊召唤到玩家tp的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材时，让玩家从连锁素材组mg2中选择融合怪兽tc所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 怪兽效果①的发动条件：当自己的表侧灵摆怪兽与对方怪兽进行战斗的伤害步骤开始时，若存在这样的战斗（攻击方或战斗目标中有一方是己方灵摆怪兽，另一方是对方怪兽），则满足条件，并将那只己方灵摆怪兽记录到效果的标签对象中。
function c46136942.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	e:SetLabelObject(a)
	return a:IsControler(tp) and a:IsFaceup() and a:IsType(TYPE_PENDULUM) and a:GetControler()~=d:GetControler()
end
-- 怪兽效果①的目标条件：检查自己场上是否有可用的怪兽区域，且手卡中的这张卡能否被特殊召唤；满足则设置操作信息为特殊召唤这张卡。
function c46136942.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查自己场上是否有空的怪兽区域，作为效果可发动的前提之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤（目标卡为自身，数量1），供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 怪兽效果①的处理：若手卡中的这张卡仍与效果关联，则将其特殊召唤；特殊召唤成功后，将之前记录的那只己方灵摆怪兽赋予不会被那次战斗破坏的效果（仅在该伤害阶段内有效）。
function c46136942.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡仍与当前效果关联，并尝试将其特殊召唤；仅当特殊召唤成功时才继续赋予战斗破坏抗性。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=e:GetLabelObject()
		if not tc:IsRelateToBattle() then return end
		-- 对应效果原文：那只自己怪兽不会被那次战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end
-- 判断卡c是否可作为融合素材且不免疫当前效果e，用于将灵摆区域的卡纳入融合素材。
function c46136942.mffilter0(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 判断卡c是否位于场上且不免疫当前效果e，用于过滤出场上可用的融合素材。
function c46136942.mffilter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 判断额外卡组中的c是否为融合怪兽、可由素材组m（并包含指定卡gc，即本卡）进行融合召唤、且能被此效果以融合召唤方式特殊召唤；用于怪兽效果②的融合召唤。
function c46136942.mffilter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 怪兽效果②的发动条件：在主要阶段检查额外卡组是否存在可由自己场上素材（含灵摆区域素材）作为融合素材、且必须包含这张卡（gc）的融合怪兽；若常规素材不足，则再检查连锁素材效果能否提供额外素材；满足则允许发动，并设置特殊召唤1只额外怪兽的操作信息。
function c46136942.mftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp当前可用的融合素材组，过滤出位于场上的卡（因为怪兽效果②只能从自己场上选择素材），得到常规场上素材组mg1。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 将灵摆区域中可作为融合素材且不免疫效果的卡并入素材组mg1，实现自己的灵摆区域素材也能作为融合素材使用。
		mg1:Merge(Duel.GetMatchingGroup(c46136942.mffilter0,tp,LOCATION_PZONE,0,nil,e))
		-- 检查额外卡组中是否存在1只融合怪兽，能用素材组mg1且必须包含这张卡c作为素材进行融合召唤，并能被此效果特殊召唤。
		local res=Duel.IsExistingMatchingCard(c46136942.mffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取连锁素材效果，用于扩展融合素材范围；若没有则为nil。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的素材组mg2和过滤条件mf，再次检查额外卡组是否存在可融合召唤且必须包含这张卡的融合怪兽。
				res=Duel.IsExistingMatchingCard(c46136942.mffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽，供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果②的处理：确认此卡仍有效后，获取场上素材（含灵摆区）作为普通素材组，并获取连锁素材组；从候选融合怪兽中选择1只；若该怪兽能用普通素材且（不使用连锁素材或玩家选择不用），则选择包含这张卡的素材送去墓地，然后融合召唤；否则使用连锁素材效果进行融合；最后完成融合召唤手续。
function c46136942.mfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取玩家tp可用的融合素材组，过滤出位于场上且不免疫当前效果的卡，得到普通素材组mg1。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c46136942.mffilter1,nil,e)
	-- 将灵摆区域中可作为融合素材且不免疫效果的卡合并到mg1，使灵摆区素材也能作为融合素材。
	mg1:Merge(Duel.GetMatchingGroup(c46136942.mffilter0,tp,LOCATION_PZONE,0,nil,e))
	-- 获取额外卡组中所有满足可用普通素材组mg1且必须包含这张卡c作为素材进行融合召唤的融合怪兽集合sg1。
	local sg1=Duel.GetMatchingGroup(c46136942.mffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果，用于扩展融合素材；若没有则为nil。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，则用连锁素材组mg2和过滤条件mf，获取额外卡组中可融合召唤且包含这张卡的融合怪兽集合sg2。
		sg2=Duel.GetMatchingGroup(c46136942.mffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示“请选择要特殊召唤的卡”的提示，供玩家选择要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽tc是否能通过普通素材组融合；若可以且（无连锁素材或玩家选择不使用连锁素材），则走普通素材路线；否则走连锁素材路线。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组mg1中选择一组融合怪兽tc所需的融合素材，且必须包含这张卡c。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，理由是效果处理以及作为融合素材。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合召唤作为独立事件处理，确保时点正确。
			Duel.BreakEffect()
			-- 将融合怪兽tc以融合召唤方式表侧表示特殊召唤到玩家tp场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材时，从连锁素材组mg2中选择融合素材，且必须包含这张卡c。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
