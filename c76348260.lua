--極星天ミーミル
-- 效果：
-- 自己场上有名字带有「极星」的怪兽表侧表示存在的场合，自己的准备阶段开始时只有1次，从手卡把1张魔法卡送去墓地才能发动。墓地存在的这张卡特殊召唤。
function c76348260.initial_effect(c)
	-- 自己场上有名字带有「极星」的怪兽表侧表示存在的场合，自己的准备阶段开始时只有1次，从手卡把1张魔法卡送去墓地才能发动。墓地存在的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76348260,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c76348260.condition)
	e1:SetCost(c76348260.cost)
	e1:SetTarget(c76348260.target)
	e1:SetOperation(c76348260.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「极星」怪兽
function c76348260.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x42)
end
-- 发动条件：自己的准备阶段开始时，且自己场上有表侧表示的「极星」怪兽存在
function c76348260.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合，且处于准备阶段开始时（尚未进行任何动作）
	return tp==Duel.GetTurnPlayer() and not Duel.CheckPhaseActivity()
		-- 检查自己场上是否存在至少1只表侧表示的「极星」怪兽
		and Duel.IsExistingMatchingCard(c76348260.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：手卡中可以送去墓地的魔法卡
function c76348260.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手卡把1张魔法卡送去墓地
function c76348260.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认手卡中是否存在可以送去墓地的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c76348260.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c76348260.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动准备：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c76348260.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍存在于墓地，则将其特殊召唤
function c76348260.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
