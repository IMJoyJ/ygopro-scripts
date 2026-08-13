--ドットスケーパー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，决斗中各能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
-- ②：这张卡被除外的场合才能发动。这张卡特殊召唤。
function c18789533.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，决斗中各能使用1次。①：这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18789533,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,18789533+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c18789533.cost)
	e1:SetTarget(c18789533.target)
	e1:SetOperation(c18789533.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,18789534+EFFECT_COUNT_CODE_DUEL)
	c:RegisterEffect(e2)
end
-- 作为发动代价的cost函数：检查并设置本回合已使用过本卡名效果的标记，用于限制这个卡名的①②的效果1回合只能有1次使用其中任意1个；若本回合尚未使用过则返回可发动（chk==0时为发动前检查），实际发动时注册到结束阶段重置的标记。
function c18789533.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：本回合尚未使用过本卡名效果（Duel.GetFlagEffect(tp,18789533)==0），即满足1回合1次的限制。
	if chk==0 then return Duel.GetFlagEffect(tp,18789533)==0 end
	-- 实际发动时：给当前玩家注册一个到结束阶段重置的标识效果（code=18789533），标记本回合已经使用过这个卡名的①②中的任意1个效果，从而本回合不能再使用另一个。
	Duel.RegisterFlagEffect(tp,18789533,RESET_PHASE+PHASE_END,0,1)
end
-- 目标/发动条件判定函数：取效果持有者（这张卡），确认主要怪兽区有空位且这张卡能够被特殊召唤，满足才可发动。
function c18789533.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件之一：玩家tp的怪兽区有空余格子，用于表侧表示特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：本次效果处理的分类为特殊召唤（CATEGORY_SPECIAL_SUMMON），对象为这张卡（1张），用于给其他卡（如星尘龙、王家长眠之谷等）正确检测这次效果处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数：效果处理时，若这张卡仍与这个效果保持关联（即没有离场或失效），则将自己特殊召唤。
function c18789533.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区；sumtype=0表示不按特定召唤方式，nocheck/nolimit为false表示仍需检查召唤条件和苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
