--吹き荒れるウィン
-- 效果：
-- 可以把自己场上除这张卡以外的1只风属性怪兽做祭品，从手卡特殊召唤1只风属性怪兽。这个效果1回合只能使用1次。这个效果特殊召唤的怪兽，在「猛吹之薇茵」从自己场上离开的场合破坏。
function c29013526.initial_effect(c)
	-- 效果原文内容：可以把自己场上除这张卡以外的1只风属性怪兽做祭品，从手卡特殊召唤1只风属性怪兽。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c29013526.spcost)
	e1:SetTarget(c29013526.sptg)
	e1:SetOperation(c29013526.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：检查并选择1只风属性怪兽进行解放作为祭品
function c29013526.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在至少1只风属性怪兽可被解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_WIND) end
	-- 效果作用：选择1只风属性怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_WIND)
	-- 效果作用：将选中的怪兽解放作为祭品
	Duel.Release(g,REASON_COST)
end
-- 效果作用：定义风属性怪兽的过滤条件
function c29013526.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：检查手牌中是否存在可特殊召唤的风属性怪兽
function c29013526.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查手牌中是否存在至少1张满足条件的风属性怪兽
		and Duel.IsExistingMatchingCard(c29013526.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：处理特殊召唤效果，包括选择怪兽、特殊召唤并注册破坏效果
function c29013526.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择手牌中满足条件的风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c29013526.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 效果原文内容：这个效果特殊召唤的怪兽，在「猛吹之薇茵」从自己场上离开的场合破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(c29013526.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
-- 效果作用：当有怪兽离开场上的时候，检查是否为薇茵离开，若是则破坏特殊召唤的怪兽
function c29013526.desop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsCode,1,nil,29013526) then
		-- 效果作用：将特殊召唤的怪兽破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
