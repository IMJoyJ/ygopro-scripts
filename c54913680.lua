--六武ノ書
-- 效果：
-- 把自己场上表侧表示存在的2只名字带有「六武众」的怪兽解放发动。从自己卡组把1只「大将军 紫炎」在自己场上特殊召唤。
function c54913680.initial_effect(c)
	-- 把自己场上表侧表示存在的2只名字带有「六武众」的怪兽解放发动。从自己卡组把1只「大将军 紫炎」在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c54913680.cost)
	e1:SetTarget(c54913680.target)
	e1:SetOperation(c54913680.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「六武众」怪兽
function c54913680.rfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 发动代价（cost）：解放自己场上2只表侧表示的「六武众」怪兽
function c54913680.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家可解放的卡片组，并过滤出表侧表示的「六武众」怪兽
	local rg=Duel.GetReleaseGroup(tp):Filter(c54913680.rfilter,nil)
	-- 在chk==0阶段，检查是否能选出2只满足解放后仍有空余怪兽区域条件的怪兽
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择2只满足解放后仍有空余怪兽区域条件的怪兽
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 使用代替解放的效果次数（如暗影敌托邦等）
	aux.UseExtraReleaseCount(sg,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(sg,REASON_COST)
end
-- 过滤条件：卡组中可以特殊召唤的「大将军 紫炎」
function c54913680.spfilter(c,e,tp)
	return c:IsCode(63176202) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查
function c54913680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断怪兽区域是否有空位（若已支付解放代价则无需在此处检查空位）
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查卡组中是否存在可以特殊召唤的「大将军 紫炎」
		return res and Duel.IsExistingMatchingCard(c54913680.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（特殊召唤「大将军 紫炎」）
function c54913680.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「大将军 紫炎」
	local g=Duel.SelectMatchingCard(tp,c54913680.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
