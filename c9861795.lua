--モグモール
-- 效果：
-- 场上的这张卡被破坏送去墓地时，这张卡可以从墓地表侧守备表示特殊召唤。「遁地鼹鼠」的效果在决斗中只能使用1次。
function c9861795.initial_effect(c)
	-- 场上的这张卡被破坏送去墓地时，这张卡可以从墓地表侧守备表示特殊召唤。「遁地鼹鼠」的效果在决斗中只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9861795,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,9861795+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c9861795.condition)
	e1:SetTarget(c9861795.target)
	e1:SetOperation(c9861795.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否因破坏而从场上送去墓地，作为效果发动的条件
function c9861795.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动的目标检查，确认己方主要怪兽区域有空位，且此卡可以以表侧守备表示特殊召唤
function c9861795.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁的操作信息，表明此效果的处理包含将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理，若怪兽区域有空位且此卡仍与效果有关联，则将此卡表侧守备表示特殊召唤
function c9861795.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡从墓地往己方场上表侧守备表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
