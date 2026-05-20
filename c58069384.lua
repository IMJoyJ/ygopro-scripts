--サイバー・ドラゴン・ノヴァ
-- 效果：
-- 机械族5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「电子龙」为对象才能发动。那只怪兽特殊召唤。
-- ②：自己·对方回合1次，从自己的手卡·场上（表侧表示）把1只「电子龙」除外才能发动。这张卡的攻击力直到回合结束时上升2100。
-- ③：这张卡被对方的效果送去墓地的场合才能发动。从额外卡组把1只机械族融合怪兽特殊召唤。
function c58069384.initial_effect(c)
	-- 设置XYZ召唤手续：机械族5星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),5,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「电子龙」为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58069384,0))  --"选择自己墓地1只「电子龙」特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c58069384.cost)
	e1:SetTarget(c58069384.target)
	e1:SetOperation(c58069384.operation)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合1次，从自己的手卡·场上（表侧表示）把1只「电子龙」除外才能发动。这张卡的攻击力直到回合结束时上升2100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58069384,1))  --"攻击力直到结束阶段时上升2100"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	-- 设置发动条件为伤害步骤中伤害计算前
	e2:SetCondition(aux.dscon)
	e2:SetCost(c58069384.atkcost)
	e2:SetOperation(c58069384.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方的效果送去墓地的场合才能发动。从额外卡组把1只机械族融合怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58069384,2))  --"特殊召唤融合怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c58069384.spcon)
	e3:SetTarget(c58069384.sptg)
	e3:SetOperation(c58069384.spop)
	c:RegisterEffect(e3)
end
-- 效果①的代价：取除这张卡的1个超量素材
function c58069384.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤墓地中可以特殊召唤的「电子龙」
function c58069384.filter(c,e,tp)
	return c:IsCode(70095154) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位、墓地是否存在「电子龙」，并选择其作为效果对象
function c58069384.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c58069384.filter(chkc,e,tp) end
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「电子龙」
		and Duel.IsExistingTarget(c58069384.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「电子龙」作为效果对象
	local g=Duel.SelectTarget(tp,c58069384.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的「电子龙」特殊召唤
function c58069384.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡或场上表侧表示可以作为代价除外的「电子龙」
function c58069384.atkfilter(c)
	return c:IsCode(70095154) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 效果②的代价：从自己的手卡或场上（表侧表示）将1只「电子龙」除外
function c58069384.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可以除外的「电子龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c58069384.atkfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择手卡或场上1只「电子龙」进行除外
	local g=Duel.SelectMatchingCard(tp,c58069384.atkfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的「电子龙」表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的效果处理：使这张卡的攻击力直到回合结束时上升2100
function c58069384.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升2100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 效果③的发动条件：这张卡在自己控制下被对方的效果送去墓地
function c58069384.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤额外卡组中可以特殊召唤的机械族融合怪兽
function c58069384.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组怪兽特殊召唤所需的场上空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③的发动准备：检查额外卡组是否存在可特殊召唤的机械族融合怪兽，并设置效果处理信息
function c58069384.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以特殊召唤的机械族融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58069384.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置效果处理信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的效果处理：从额外卡组选择1只机械族融合怪兽特殊召唤
function c58069384.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的机械族融合怪兽
	local g=Duel.SelectMatchingCard(tp,c58069384.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的机械族融合怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
