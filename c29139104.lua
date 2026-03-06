--荒ぶるアウス
-- 效果：
-- 可以把自己场上除这张卡以外的1只地属性怪兽做祭品，从手卡特殊召唤1只地属性怪兽。这个效果1回合只能使用1次。这个效果特殊召唤的怪兽，在「荒狂之奥丝」从自己场上离开的场合破坏。
function c29139104.initial_effect(c)
	-- 效果原文内容：可以把自己场上除这张卡以外的1只地属性怪兽做祭品，从手卡特殊召唤1只地属性怪兽。这个效果1回合只能使用1次。这个效果特殊召唤的怪兽，在「荒狂之奥丝」从自己场上离开的场合破坏。
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
-- 检查是否满足祭品条件并选择祭品怪兽
function c29139104.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_EARTH) end
	-- 选择1只满足条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_EARTH)
	-- 将选中的怪兽解放作为效果的代价
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于筛选可以特殊召唤的地属性怪兽
function c29139104.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件
function c29139104.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c29139104.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果的主逻辑
function c29139104.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c29139104.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 效果原文内容：这个效果特殊召唤的怪兽，在「荒狂之奥丝」从自己场上离开的场合破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(c29139104.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
-- 当有怪兽离开场上的时候触发的效果
function c29139104.desop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsCode,1,nil,29139104) then
		-- 将该怪兽破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
