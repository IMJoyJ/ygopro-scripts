--逆巻くエリア
-- 效果：
-- 可以把自己场上除这张卡以外的1只水属性怪兽做祭品，从手卡特殊召唤1只水属性怪兽。这个效果1回合只能使用1次。这个效果特殊召唤的怪兽，在「逆卷之艾莉娅」从自己场上离开的场合破坏。
function c56524813.initial_effect(c)
	-- 可以把自己场上除这张卡以外的1只水属性怪兽做祭品，从手卡特殊召唤1只水属性怪兽。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c56524813.spcost)
	e1:SetTarget(c56524813.sptg)
	e1:SetOperation(c56524813.spop)
	c:RegisterEffect(e1)
end
-- 支付发动代价：解放自己场上除这张卡以外的1只水属性怪兽。
function c56524813.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除这张卡以外、可以解放的1只水属性怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_WATER) end
	-- 玩家选择场上除这张卡以外的1只水属性怪兽。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_WATER)
	-- 解放选择的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：手牌中的水属性且可以特殊召唤的怪兽。
function c56524813.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：检查怪兽区域是否有空位，以及手牌中是否存在符合条件的水属性怪兽，并设置特殊召唤的操作信息。
function c56524813.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只可以特殊召唤的水属性怪兽。
		and Duel.IsExistingMatchingCard(c56524813.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手牌特殊召唤1只水属性怪兽，并为该怪兽添加“「逆卷之艾莉娅」从自己场上离开的场合破坏”的效果。
function c56524813.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若无空位则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌选择1只符合条件的水属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c56524813.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽，在「逆卷之艾莉娅」从自己场上离开的场合破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(c56524813.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
-- 破坏效果处理：如果离开场上的卡中包含「逆卷之艾莉娅」，则破坏该特殊召唤的怪兽。
function c56524813.desop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsCode,1,nil,56524813) then
		-- 破坏该特殊召唤的怪兽。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
