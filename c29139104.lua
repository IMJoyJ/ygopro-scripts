--荒ぶるアウス
-- 效果：
-- 可以把自己场上除这张卡以外的1只地属性怪兽做祭品，从手卡特殊召唤1只地属性怪兽。这个效果1回合只能使用1次。这个效果特殊召唤的怪兽，在「荒狂之奥丝」从自己场上离开的场合破坏。
function c29139104.initial_effect(c)
	-- 可以把自己场上除这张卡以外的1只地属性怪兽做祭品，从手卡特殊召唤1只地属性怪兽。这个效果1回合只能使用1次。这个效果特殊召唤的怪兽，在「荒狂之奥丝」从自己场上离开的场合破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c29139104.spcost)
	e1:SetTarget(c29139104.sptg)
	e1:SetOperation(c29139104.spop)
	c:RegisterEffect(e1)
end
-- 代价处理函数：先检查是否存在可解放的地属性怪兽作为代价，存在则选择并解放；用于支付“把自己场上除这张卡以外的1只地属性怪兽做祭品”这一代价。
function c29139104.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认自己场上是否存在1只除自身以外的地属性怪兽可以解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_EARTH) end
	-- 选择要解放的1只地属性怪兽（除自身以外）。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_EARTH)
	-- 将选择的怪兽作为代价解放。
	Duel.Release(g,REASON_COST)
end
-- 手卡怪兽的筛选条件：必须是地属性，且能够被当前效果特殊召唤。
function c29139104.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标判定：确认自己主要怪兽区有空位，且手卡中存在符合条件的1只地属性怪兽。
function c29139104.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足filter条件的地属性怪兽。
		and Duel.IsExistingMatchingCard(c29139104.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果处理的信息：将从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：特殊召唤手卡中的1只地属性怪兽，并给那只怪兽注册一个持续监视效果，当「荒狂之奥丝」离场时将其破坏。
function c29139104.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区仍有空位，否则效果处理不适用直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足filter条件的地属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c29139104.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽，在「荒狂之奥丝」从自己场上离开的场合破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(c29139104.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
-- 离场时的诱发处理：当「荒狂之奥丝」从场上离开时，破坏持有此效果的那只特殊召唤怪兽。
function c29139104.desop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsCode,1,nil,29139104) then
		-- 以效果原因将持有该效果的特殊召唤怪兽破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
