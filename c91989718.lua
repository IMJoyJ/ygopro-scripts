--アタック・リフレクター・ユニット
-- 效果：
-- 把自己场上1只「电子龙」作为祭品才能发动。从自己的手卡·卡组特殊召唤1只「电子障壁龙」。
function c91989718.initial_effect(c)
	-- 把自己场上1只「电子龙」作为祭品才能发动。从自己的手卡·卡组特殊召唤1只「电子障壁龙」。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c91989718.cost)
	e1:SetTarget(c91989718.target)
	e1:SetOperation(c91989718.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）：解放自己场上1只「电子龙」
function c91989718.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的「电子龙」
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,70095154) end
	-- 选择自己场上1只「电子龙」作为解放对象
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,70095154)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：手卡或卡组中可以特殊召唤的「电子障壁龙」
function c91989718.spfilter(c,e,tp)
	return c:IsCode(68774379) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 发动效果的目标检查（Target）：确认怪兽区域空位以及手卡·卡组中是否存在可特殊召唤的「电子障壁龙」
function c91989718.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空位（考虑解放Cost后，空位数需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在满足特殊召唤条件的「电子障壁龙」
		and Duel.IsExistingMatchingCard(c91989718.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理（Operation）：从手卡或卡组特殊召唤1只「电子障壁龙」
function c91989718.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只「电子障壁龙」
	local g=Duel.SelectMatchingCard(tp,c91989718.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 无视召唤条件特殊召唤选中的怪兽
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
