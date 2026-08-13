--ディメンジョン・ダイス
-- 效果：
-- ①：持有掷骰子效果的卡在自己场上存在的场合，把自己场上1只怪兽解放才能发动。把持有掷骰子的怪兽效果的1只怪兽从手卡·卡组特殊召唤。
function c47292920.initial_effect(c)
	-- ①：持有掷骰子效果的卡在自己场上存在的场合，把自己场上1只怪兽解放才能发动。把持有掷骰子的怪兽效果的1只怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c47292920.spcon)
	e1:SetCost(c47292920.cost)
	e1:SetTarget(c47292920.target)
	e1:SetOperation(c47292920.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：用于判断一张卡是否为持有掷骰子效果的卡（表侧表示且拥有掷骰子效果）。
function c47292920.cfilter(c)
	-- 返回该卡是否为表侧表示，并且其效果带有掷骰子效果标记（EFFECT_FLAG_DICE）。
	return c:IsFaceup() and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_DICE))
end
-- 定义效果的发动条件函数：检查自己场上是否存在满足条件的持有掷骰子效果的卡。
function c47292920.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示且持有掷骰子效果的卡。
	return Duel.IsExistingMatchingCard(c47292920.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义代价过滤函数：用于选择要解放的怪兽时，确认解放后自己场上仍有空余的怪兽区域可进行后续特殊召唤。
function c47292920.costfilter(c,tp)
	-- 返回解放这张卡c后，自己场上是否还有空余的怪兽区域。
	return Duel.GetMZoneCount(tp,c)>0
end
-- 定义代价执行函数：先标记已经支付过解放代价，再检查能否解放1只满足条件的怪兽，并实际选择解放1只怪兽发动。
function c47292920.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在代价检查阶段，确认自己场上是否存在至少1只满足解放后仍有空位条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c47292920.costfilter,1,nil,tp) end
	-- 从自己场上选择1只满足解放后仍有空位条件的怪兽，作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,c47292920.costfilter,1,1,nil,tp)
	-- 将选择的怪兽解放，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤候选过滤函数：筛选持有掷骰子怪兽效果的怪兽，确认其可以特殊召唤。
function c47292920.spfilter(c,e,tp)
	-- 筛选对象为怪兽卡，且其怪兽效果带有掷骰子效果标记（排除灵摆区域效果）。
	return c:IsType(TYPE_MONSTER) and c:IsEffectProperty(aux.MonsterEffectPropertyFilter(EFFECT_FLAG_DICE))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时目标确认与操作信息设置：在检查阶段确认已解放怪兽或仍有空位，并确认存在可特殊召唤的怪兽；在发动时设置将进行特殊召唤的操作信息。
function c47292920.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算是否满足已解放过怪兽（e:GetLabel()==1）或当前场上仍有空余怪兽区域的发动条件，以应对检查顺序。
		local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		e:SetLabel(0)
		-- 确认满足空位条件，并且手卡·卡组中存在至少1只可特殊召唤的持有掷骰子怪兽效果的怪兽。
		return res and Duel.IsExistingMatchingCard(c47292920.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 系统登记本次效果处理为：从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果处理时的操作：若场上还有空位，则选择符合条件的1只怪兽以表侧表示特殊召唤。
function c47292920.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上有空余的怪兽区域，若没有则本效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1只满足spfilter条件的怪兽（持有掷骰子怪兽效果且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c47292920.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
