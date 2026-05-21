--餅カエル
-- 效果：
-- 水族2星怪兽×2
-- ①：双方的准备阶段，把这张卡1个超量素材取除才能发动。从卡组把1只「青蛙」怪兽特殊召唤。
-- ②：1回合1次，对方把怪兽的效果·魔法·陷阱卡发动时，从自己的手卡·场上（表侧表示）把1只水族怪兽送去墓地才能发动。那个发动无效并破坏。那之后，可以把破坏的卡在自己场上盖放。
-- ③：这张卡被送去墓地的场合，以自己墓地1只水属性怪兽为对象才能发动。那只加入手卡。
function c90809975.initial_effect(c)
	-- 设置XYZ召唤手续：水族2星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),2,2)
	c:EnableReviveLimit()
	-- ①：双方的准备阶段，把这张卡1个超量素材取除才能发动。从卡组把1只「青蛙」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90809975,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c90809975.spcost)
	e1:SetTarget(c90809975.sptg)
	e1:SetOperation(c90809975.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方把怪兽的效果·魔法·陷阱卡发动时，从自己的手卡·场上（表侧表示）把1只水族怪兽送去墓地才能发动。那个发动无效并破坏。那之后，可以把破坏的卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90809975,1))  --"无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c90809975.negcon)
	e2:SetCost(c90809975.negcost)
	e2:SetTarget(c90809975.negtg)
	e2:SetOperation(c90809975.negop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以自己墓地1只水属性怪兽为对象才能发动。那只加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90809975,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c90809975.thtg)
	e3:SetOperation(c90809975.thop)
	c:RegisterEffect(e3)
end
-- 效果①的COST：取除这张卡的1个超量素材
function c90809975.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「青蛙」怪兽
function c90809975.spfilter(c,e,tp)
	return c:IsSetCard(0x12) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域是否有空位，以及卡组中是否存在可特殊召唤的「青蛙」怪兽，并设置特殊召唤的操作信息
function c90809975.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「青蛙」怪兽
		and Duel.IsExistingMatchingCard(c90809975.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1只「青蛙」怪兽特殊召唤
function c90809975.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足条件的「青蛙」怪兽
	local g=Duel.SelectMatchingCard(tp,c90809975.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：对方发动怪兽效果、魔法或陷阱卡，且该发动可以被无效，此卡不在伤害步骤被战斗破坏
function c90809975.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查发动的效果是否为怪兽效果、魔法或陷阱卡的发动，且该发动可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 过滤手卡或场上表侧表示的、可以送去墓地作为COST的水族怪兽
function c90809975.cfilter(c)
	return c:IsRace(RACE_AQUA) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
-- 效果②的COST：将自己手卡或场上表侧表示的一只水族怪兽送去墓地
function c90809975.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可送去墓地的水族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90809975.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1只手卡或场上表侧表示的水族怪兽
	local g=Duel.SelectMatchingCard(tp,c90809975.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为COST送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的发动准备：设置无效与破坏的操作信息，并根据被无效卡片的类型动态调整效果分类（怪兽卡增加特殊召唤/盖放怪兽，魔陷卡增加盖放魔陷）
function c90809975.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	if bit.band(re:GetHandler():GetOriginalType(),TYPE_MONSTER)~=0 then
		e:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_MSET)
	else
		e:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SSET)
	end
end
-- 效果②的效果处理：使发动无效并破坏，之后可以把破坏的卡在自己场上盖放
function c90809975.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 尝试使该连锁的发动无效，若失败则结束处理
	if not Duel.NegateActivation(ev) then return end
	-- 检查卡片是否仍与效果关联，并将其破坏，若破坏成功则继续处理
	if rc:IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0
		and not (rc:IsLocation(LOCATION_HAND+LOCATION_DECK) or rc:IsLocation(LOCATION_REMOVED) and rc:IsFacedown())
		-- 检查被破坏的卡是否不受「王家长眠之谷」的影响
		and aux.NecroValleyFilter()(rc) then
		-- 检查被破坏的卡是否为怪兽，且若不是额外卡组怪兽时自己场上是否有空余的怪兽区域
		if rc:IsType(TYPE_MONSTER) and (not rc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 或者该怪兽在额外卡组表侧表示存在，且自己场上有空余的额外怪兽区域
				or rc:IsLocation(LOCATION_EXTRA) and rc:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,rc)>0)
			and rc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 询问玩家是否选择将破坏的怪兽在自己场上盖放
			and Duel.SelectYesNo(tp,aux.Stringid(90809975,3)) then  --"是否把破坏的卡在自己场上盖放？"
			-- 中断当前效果，使后续的盖放处理与破坏不视为同时进行
			Duel.BreakEffect()
			-- 将破坏的怪兽以里侧守备表示特殊召唤（盖放）到自己场上
			Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 让对方玩家确认盖放的怪兽
			Duel.ConfirmCards(1-tp,rc)
		-- 否则，如果被破坏的卡是魔法·陷阱卡，且是场地魔法或者自己场上有空余的魔法·陷阱区域
		elseif (rc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
			-- 检查该卡是否可以盖放，并询问玩家是否选择将其在自己场上盖放
			and rc:IsSSetable(true) and Duel.SelectYesNo(tp,aux.Stringid(90809975,4)) then  --"是否把破坏的卡在自己场上盖放？"
			-- 中断当前效果，使后续的盖放处理与破坏不视为同时进行
			Duel.BreakEffect()
			-- 将破坏的魔法·陷阱卡在自己场上盖放
			Duel.SSet(tp,rc)
		end
	end
end
-- 过滤墓地中可以加入手卡的水属性怪兽
function c90809975.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 效果③的发动准备：选择自己墓地1只水属性怪兽作为对象，并设置加入手卡的操作信息
function c90809975.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90809975.thfilter(chkc) end
	-- 检查自己墓地是否存在可加入手卡的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c90809975.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地1只水属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c90809975.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将目标卡片加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的效果处理：将作为对象的水属性怪兽加入手卡
function c90809975.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
