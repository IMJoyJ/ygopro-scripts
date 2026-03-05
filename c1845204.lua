--簡易融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000基本分才能发动。把1只5星以下的融合怪兽当作融合召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
function c1845204.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
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
-- 规则层面操作：检查玩家是否能支付1000基本分
function c1845204.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 规则层面操作：让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 规则层面操作：定义过滤函数，筛选满足条件的融合怪兽
function c1845204.filter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsLevelBelow(5) and c:CheckFusionMaterial()
		-- 规则层面操作：检查融合怪兽是否可以特殊召唤且场上是否有足够位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果原文内容：①：支付1000基本分才能发动。
function c1845204.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家是否满足融合素材要求
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 规则层面操作：检查额外卡组是否存在满足条件的融合怪兽
		and Duel.IsExistingMatchingCard(c1845204.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果原文内容：把1只5星以下的融合怪兽当作融合召唤从额外卡组特殊召唤。
function c1845204.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：再次检查玩家是否满足融合素材要求
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：从额外卡组选择满足条件的1只融合怪兽
	local g=Duel.SelectMatchingCard(tp,c1845204.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 规则层面操作：将选中的融合怪兽以融合召唤方式特殊召唤
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 效果原文内容：这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(1845204,RESET_EVENT+RESETS_STANDARD,0,1)
		tc:CompleteProcedure()
		-- 效果原文内容：这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(c1845204.descon)
		-- 规则层面操作：设置破坏操作
		e2:SetOperation(aux.EPDestroyOperation)
		-- 规则层面操作：注册结束阶段破坏效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 规则层面操作：判断是否需要触发破坏效果
function c1845204.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(1845204)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
