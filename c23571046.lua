--ボルト・ヘッジホッグ
-- 效果：
-- ①：自己主要阶段才能发动。这张卡从墓地特殊召唤。这个效果在自己场上有调整存在的场合才能发动和处理。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c23571046.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡从墓地特殊召唤。这个效果在自己场上有调整存在的场合才能发动和处理。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 此过滤函数用于筛选出表侧表示且为调整的怪兽。
function c23571046.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 该效果的发动条件函数：自己场上有表侧表示调整怪兽存在时才能发动。
function c23571046.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的调整怪兽。
	return Duel.IsExistingMatchingCard(c23571046.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 目标函数：在发动时检查是否有空位且自身能否被特殊召唤；实际没有选择对象。
function c23571046.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空闲区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，标明了本连锁将特殊召唤的对象（这张卡），供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：处理时再次确认场上仍有调整；若这张卡仍与效果关联，则将其特殊召唤，成功召唤后赋予其离场时除外而非去墓地的效果。
function c23571046.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再确认自己场上仍然存在表侧表示调整怪兽，否则不处理（对应“才能发动和处理”的后半部分）。
	if not Duel.IsExistingMatchingCard(c23571046.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	local c=e:GetHandler()
	-- 确认这张卡仍与该效果相关联（即未脱离效果关系），并实际成功特殊召唤为表侧表示。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
