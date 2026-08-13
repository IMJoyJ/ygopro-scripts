--フュージョン・ゲート
-- 效果：
-- ①：双方玩家在自己主要阶段才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。
function c33550694.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：双方玩家在自己主要阶段才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33550694,0))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetTarget(c33550694.target)
	e2:SetOperation(c33550694.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：作为融合素材的怪兽必须能够被除外，且不免疫此效果。
function c33550694.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 检查额外卡组中的怪兽是否为融合怪兽、是否满足可用的追加融合素材条件、能否以融合召唤方式特殊召唤，以及当前素材组是否满足其融合素材要求。
function c33550694.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动的合法判定与操作信息设定：在发动时检查是否存在能用当前可用素材（手卡·场上可除外的怪兽以及连锁素材）融合召唤的融合怪兽；若存在则允许发动，并设置特殊召唤的操作信息。
function c33550694.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组（手卡·场上怪兽及受额外融合素材效果影响的卡），并筛选出其中能够被除外的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToRemove,nil)
		-- 检查额外卡组中是否存在至少1只融合怪兽，能由上述可除外的素材组满足融合素材条件并被融合召唤。
		local res=Duel.IsExistingMatchingCard(c33550694.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家适用的连锁素材效果（若有），用于扩大可选的融合素材范围。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材，则使用连锁素材提供的素材组，再次检查额外卡组中是否存在可被融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c33550694.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果将从额外卡组特殊召唤1只怪兽，供后续效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的实际操作：选择要融合召唤的融合怪兽，选择素材，除外素材，然后进行融合召唤；若涉及连锁素材则分支处理。
function c33550694.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取普通融合素材组，并过滤掉不能被除外或免疫此效果的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c33550694.filter1,nil,e)
	-- 获取利用普通素材组能够融合召唤的融合怪兽集合。
	local sg1=Duel.GetMatchingGroup(c33550694.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果处理时获取玩家适用的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组，获取能够融合召唤的融合怪兽集合。
		sg2=Duel.GetMatchingGroup(c33550694.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发出选择提示，要求选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否只属于普通素材可召唤（或玩家不使用连锁素材）；若使用普通素材则走普通融合流程，否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组中为选定的融合怪兽选择一组满足条件的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材怪兽以表侧表示除外，除外的原因包含效果、作为融合素材和融合召唤。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤视为独立处理，避免与素材除外同时处理导致错失时点。
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤方式特殊召唤到发动者场上，表侧表示。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材组中为选定的融合怪兽选择一组满足条件的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
