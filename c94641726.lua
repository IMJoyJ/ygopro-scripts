--Storm-Bane Dragon Destorbim
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 对方不能把这张卡作为效果的对象。
-- 「岚祸龙 迪斯托宾」的以下效果1回合各能使用1次。
-- 可以从自己墓地把不能通常召唤的暗属性怪兽任意数量除外；把那个数量的对方场上的卡除外。对方场上的卡比自己场上多的场合，这个效果在对方回合也能发动。
-- 这张卡被送去墓地的场合：可以把自己除外状态的1只龙族怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的效果，包括同调召唤手续、不能成为对方效果对象、除外对方场上卡的效果（包含自己回合起动效果与对方回合诱发即时效果两个版本）以及送墓时特殊召唤除外状态龙族怪兽的效果。
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	-- 设置不能成为效果对象的范围为对方玩家卡片的效果。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 可以从自己墓地把不能通常召唤的暗属性怪兽任意数量除外；把那个数量的对方场上的卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外效果"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon1)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(s.rmcon2)
	c:RegisterEffect(e3)
	-- 这张卡被送去墓地的场合：可以把自己除外状态的1只龙族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 检查对方场上的卡是否不比自己场上的卡多，作为自己回合主要阶段发动起动效果的条件。
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 计算对方场上的卡片数量与自己场上的卡片数量的差值。
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	return ct<=0
end
-- 检查对方场上的卡是否比自己场上多，作为在对方回合也能发动该效果的条件。
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 计算对方场上的卡片数量与自己场上的卡片数量的差值。
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	return ct>0
end
-- 过滤自己墓地中不能通常召唤的暗属性且可以被除外的怪兽。
function s.cfilter(c)
	return not c:IsSummonableCard() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的消耗：从自己墓地选择任意数量满足条件的怪兽除外，并记录除外的数量。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算对方场上可以被除外的卡片数量，以此限制自己墓地除外卡片的上限。
	local ct=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 步骤1的检查：自己墓地是否存在至少1只满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张到对方场上可除外卡片数量上限的满足条件的怪兽。
	local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 将选中的怪兽作为发动成本表侧表示除外。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	e:SetLabel(sg:GetCount())
end
-- 效果的目标处理：检查对方场上是否存在可除外的卡，并设置除外操作的连锁信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查对方场上是否存在至少1张可以被除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以被除外的卡片。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁信息，表明此效果将除外对方场上与cost除外数量相同的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,e:GetLabel(),0,0)
end
-- 效果的运行空间：选择并除外与cost除外数量相同的对方场上的卡。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 如果对方场上可除外的卡片数量少于cost除外的数量，则不处理效果。
	if Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)<ct then return end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择与cost除外数量相同的对方场上的卡。
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	if #sg>0 then
		-- 闪烁显示被选中的对方场上的卡片。
		Duel.HintSelection(sg)
		-- 将选中的对方场上的卡片表侧表示除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤自己除外状态的、可以特殊召唤的表侧表示龙族怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的目标处理：检查怪兽区域是否有空位，以及是否存在可特殊召唤的除外状态龙族怪兽，并设置特殊召唤的连锁信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤1的检查：自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己除外状态中是否存在至少1只满足特殊召唤条件的龙族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁信息，表明此效果将从除外状态特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 效果的运行空间：选择自己除外状态的1只龙族怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己除外状态的1只满足条件的龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
