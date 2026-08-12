--燃え盛るヒータ
-- 效果：
-- 可以把自己场上除这张卡以外的1只炎属性怪兽做祭品，从手卡特殊召唤1只炎属性怪兽。这个效果1回合只能使用1次。这个效果特殊召唤的怪兽，在「盛燃之希塔」从自己场上离开的场合破坏。
function c92518817.initial_effect(c)
	-- 可以把自己场上除这张卡以外的1只炎属性怪兽做祭品，从手卡特殊召唤1只炎属性怪兽。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c92518817.spcost)
	e1:SetTarget(c92518817.sptg)
	e1:SetOperation(c92518817.spop)
	c:RegisterEffect(e1)
end
-- 定义发动代价：解放自己场上除这张卡以外的1只炎属性怪兽
function c92518817.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外的可解放的炎属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_FIRE) end
	-- 选择自己场上除这张卡以外的1只可解放的炎属性怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_FIRE)
	-- 解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：手卡中可以特殊召唤的炎属性怪兽
function c92518817.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动的目标检查与操作信息设置
function c92518817.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以特殊召唤的炎属性怪兽
		and Duel.IsExistingMatchingCard(c92518817.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义效果处理：特殊召唤手卡的炎属性怪兽，并注册离场时破坏的效果
function c92518817.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c92518817.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽，在「盛燃之希塔」从自己场上离开的场合破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(c92518817.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
-- 定义破坏效果的处理：若「盛燃之希塔」离场，则破坏该怪兽
function c92518817.desop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsCode,1,nil,92518817) then
		-- 因效果破坏该怪兽
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
