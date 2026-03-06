--ボルト・ヘッジホッグ
-- 效果：
-- ①：自己主要阶段才能发动。这张卡从墓地特殊召唤。这个效果在自己场上有调整存在的场合才能发动和处理。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c23571046.initial_effect(c)
	-- 效果原文内容：①：自己主要阶段才能发动。这张卡从墓地特殊召唤。这个效果在自己场上有调整存在的场合才能发动和处理。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23571046,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c23571046.condition)
	e1:SetTarget(c23571046.target)
	e1:SetOperation(c23571046.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：定义过滤函数，用于检测场上是否存在表侧表示的调整怪兽。
function c23571046.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 效果作用：判断是否满足发动条件，即自己场上是否存在至少1只调整怪兽。
function c23571046.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查自己场上是否存在至少1只调整怪兽。
	return Duel.IsExistingMatchingCard(c23571046.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：设置效果的目标，判断是否可以将此卡特殊召唤。
function c23571046.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查自己场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 效果作用：设置连锁处理信息，声明本次效果将特殊召唤1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果作用：执行效果的处理流程，包括检查条件、特殊召唤卡片并设置离场时除外的效果。
function c23571046.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：再次确认自己场上是否存在调整怪兽，若不存在则效果不处理。
	if not Duel.IsExistingMatchingCard(c23571046.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	local c=e:GetHandler()
	-- 效果作用：判断此卡是否与效果相关联，并尝试将其特殊召唤到场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 效果原文内容：这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
