--暗黒のマンティコア
-- 效果：
-- 这张卡被送去墓地的回合的结束阶段时，从自己的手卡·场上把1只兽族·兽战士族·鸟兽族怪兽送去墓地才能发动。这张卡从墓地特殊召唤。
function c77121851.initial_effect(c)
	-- 这张卡被送去墓地的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c77121851.tgop)
	c:RegisterEffect(e1)
	-- 结束阶段时，从自己的手卡·场上把1只兽族·兽战士族·鸟兽族怪兽送去墓地才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77121851,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c77121851.spcon)
	e2:SetCost(c77121851.spcost)
	e2:SetTarget(c77121851.sptg)
	e2:SetOperation(c77121851.spop)
	c:RegisterEffect(e2)
end
-- 在自身被送去墓地时（排除回到卡组或规则调整等情况），注册一个在该回合结束阶段前有效的Flag，用于标记其被送去墓地的状态。
function c77121851.tgop(e,tp,eg,ep,ev,re,r,rp)
	if bit.band(r,REASON_RETURN+REASON_ADJUST)~=0 then return end
	e:GetHandler():RegisterFlagEffect(77121851,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查自身是否带有被送去墓地回合的Flag，以此作为发动效果的条件。
function c77121851.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(77121851)~=0
end
-- 过滤满足作为Cost送去墓地条件的卡：手卡或场上表侧表示的兽族、兽战士族或鸟兽族怪兽。
function c77121851.costfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
-- 效果发动的Cost处理：检查怪兽区域空位数，并从手卡或场上选择1只满足条件的兽族/兽战士族/鸟兽族怪兽送去墓地。
function c77121851.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家怪兽区域的可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_HAND+LOCATION_MZONE
	if ft<1 then loc=LOCATION_MZONE end
	-- 在chk==0时，判断怪兽区域是否有空位（若无空位，则必须从场上选择怪兽送去墓地以腾出空位），且存在至少1只可作为Cost送去墓地的怪兽。
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c77121851.costfilter,tp,loc,0,1,nil) end
	-- 给玩家发送提示信息，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或场上选择1只满足条件的兽族/兽战士族/鸟兽族怪兽。
	local g=Duel.SelectMatchingCard(tp,c77121851.costfilter,tp,loc,0,1,1,nil)
	-- 将选中的怪兽作为发动Cost送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动的Target处理：检查自身是否能特殊召唤，并设置特殊召唤的操作信息。
function c77121851.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若自身仍在墓地，则将自身特殊召唤。
function c77121851.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
