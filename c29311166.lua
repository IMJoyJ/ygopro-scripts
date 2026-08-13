--アサルトワイバーン
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时，把这张卡解放才能发动。从自己的手卡·墓地选「强袭翼龙」以外的1只龙族怪兽特殊召唤。
function c29311166.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽时，把这张卡解放才能发动。从自己的手卡·墓地选「强袭翼龙」以外的1只龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29311166,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件：本卡与对方怪兽战斗并将其战斗破坏（使用辅助函数判定本卡与战斗相关且攻击对象为对方怪兽）。
	e1:SetCondition(aux.bdocon)
	e1:SetCost(c29311166.cost)
	e1:SetTarget(c29311166.target)
	e1:SetOperation(c29311166.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择「强袭翼龙」以外的龙族怪兽，且该怪兽能被当前效果特殊召唤（仍需检查召唤条件和苏生限制）。
function c29311166.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and not c:IsCode(29311166) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 代价函数：发动前检查本卡是否可以被解放；若可以，则解放本卡作为发动代价。
function c29311166.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价解放的形式将效果持有者（这张卡）送去墓地。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果发动时的目标判定：检查自己场上是否有可用怪兽区域，并且手卡·墓地存在符合条件的龙族怪兽。
function c29311166.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在可用空格（若解放后腾出位置，此处用>-1兼容处理）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 同时确认手卡·墓地中至少有1张满足filter条件的龙族怪兽。
		and Duel.IsExistingMatchingCard(c29311166.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果处理包含特殊召唤分类，预定从手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理函数：实际进行特殊召唤，若没有空位或没有可选卡则结束。
function c29311166.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有可用怪兽区域，则效果不处理，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡·墓地中选择1张满足filter且不受王家长眠之谷影响的龙族怪兽（「强袭翼龙」除外）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29311166.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，不无视召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
