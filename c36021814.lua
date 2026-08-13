--ワイトキング
-- 效果：
-- ①：这张卡的原本攻击力变成自己墓地的「白骨王」「白骨」数量×1000。
-- ②：这张卡被战斗破坏送去墓地时，从自己墓地把1只其他的「白骨王」或「白骨」除外才能发动。这张卡特殊召唤。
function c36021814.initial_effect(c)
	-- 将白骨王的效果文本中记载的「白骨」（32274490）加入代码列表，用于系统识别这张卡与「白骨」的关联。
	aux.AddCodeList(c,32274490)
	-- ①：这张卡的原本攻击力变成自己墓地的「白骨王」「白骨」数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c36021814.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时，从自己墓地把1只其他的「白骨王」或「白骨」除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36021814,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c36021814.condition)
	e2:SetCost(c36021814.cost)
	e2:SetTarget(c36021814.target)
	e2:SetOperation(c36021814.operation)
	c:RegisterEffect(e2)
end
-- 计算白骨王的原本攻击力：统计自己墓地中卡名为「白骨王」或「白骨」的卡的数量，并将该数量乘以1000。
function c36021814.atkval(e,c)
	-- 统计自己墓地中卡名为「白骨王」/「白骨」的卡的数量，乘以1000作为原本攻击力。
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,nil,32274490,36021814)*1000
end
-- ②效果的发动条件：这张卡被战斗破坏并送去墓地，即判定此卡位于墓地且破坏原因是战斗破坏。
function c36021814.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and bit.band(e:GetHandler():GetReason(),REASON_BATTLE)~=0
end
-- ②效果代价的过滤条件：卡名是「白骨王」或「白骨」，并且可以作为代价从墓地除外。
function c36021814.costfilter(c)
	return c:IsCode(32274490,36021814) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价：从自己墓地把1只其他的「白骨王」或「白骨」除外；先检查是否存在可选卡，再提示选择并除外。
function c36021814.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己墓地存在至少1张满足代价条件且不是这张卡的「白骨王」或「白骨」。
	if chk==0 then return Duel.IsExistingMatchingCard(c36021814.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家发送“请选择要除外的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的「白骨王」或「白骨」（排除这张卡自身）作为代价。
	local g=Duel.SelectMatchingCard(tp,c36021814.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡片以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果发动时的合法性检查：确认自己场上有可用的怪兽区，且这张卡自身可以被特殊召唤。
function c36021814.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区是否有空位（若没有空位则不能发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：该效果将把这张卡自身特殊召唤，数量为1，属于特殊召唤分类。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理时的实际特殊召唤操作：确认仍有怪兽区空位且这张卡仍与此效果关联后，将其表侧表示特殊召唤到自己场上。
function c36021814.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己场上没有可用怪兽区则终止处理，无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
