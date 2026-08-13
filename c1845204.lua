--簡易融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000基本分才能发动。把1只5星以下的融合怪兽当作融合召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
function c1845204.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：支付1000基本分才能发动。把1只5星以下的融合怪兽当作融合召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1845204+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c1845204.cost)
	e1:SetTarget(c1845204.target)
	e1:SetOperation(c1845204.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：支付1000基本分才能发动，先检查LP是否足够。
function c1845204.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认玩家能否支付1000基本分，用于代价检查。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际扣除玩家1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 筛选函数：从额外卡组选择1只5星以下的融合怪兽，且满足融合素材条件和融合召唤资格，并确认额外怪兽区域有空位。
function c1845204.filter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsLevelBelow(5) and c:CheckFusionMaterial()
		-- 进一步判定该怪兽能否以融合召唤方式特殊召唤，以及额外怪兽区域是否有足够的空格。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动目标函数：确认额外卡组存在符合条件的融合怪兽，且满足‘必须作为融合素材’的卡的限制，以决定能否发动。
function c1845204.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认不存在因‘必须作为融合素材’效果而导致的非法发动情况（若有此类卡则需以其为素材，这里检查能否满足）。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组是否存在至少1只满足过滤条件的融合怪兽。
		and Duel.IsExistingMatchingCard(c1845204.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将把额外卡组的1只怪兽特殊召唤，用于后续连锁检测和效果处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：选择符合条件的融合怪兽以融合召唤方式特殊召唤，并为其附加不能攻击和结束阶段破坏的效果。
function c1845204.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认‘必须作为融合素材’的限制未被破坏，否则中止处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c1845204.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选择的怪兽以融合召唤方式特殊召唤；若成功则进入后续附加效果处理。
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(1845204,RESET_EVENT+RESETS_STANDARD,0,1)
		tc:CompleteProcedure()
		-- 结束阶段破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(c1845204.descon)
		-- 设置结束阶段时执行的破坏操作，将那只怪兽破坏。
		e2:SetOperation(aux.EPDestroyOperation)
		-- 将结束阶段破坏效果注册到场上，由当前玩家控制，在结束阶段统一处理。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 条件函数：若被特殊召唤的怪兽仍带有本次效果标记，则在结束阶段破坏；若怪兽已离场或标记消失，则重置该效果不再处理。
function c1845204.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(1845204)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
