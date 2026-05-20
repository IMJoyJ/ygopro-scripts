--ウォークライ・フォティア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的战士族·地属性怪兽进行战斗的伤害计算后才能发动。从卡组把「战吼斗士·福蒂亚」以外的1张「战吼」卡加入手卡。那之后，自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
-- ②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
function c83286340.initial_effect(c)
	-- ①：自己的战士族·地属性怪兽进行战斗的伤害计算后才能发动。从卡组把「战吼斗士·福蒂亚」以外的1张「战吼」卡加入手卡。那之后，自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83286340,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCountLimit(1,83286340)
	e1:SetTarget(c83286340.thtg)
	e1:SetOperation(c83286340.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83286340,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,83286341)
	e2:SetCondition(c83286340.spcon)
	e2:SetTarget(c83286340.sptg)
	e2:SetOperation(c83286340.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「战吼斗士·福蒂亚」以外的「战吼」卡
function c83286340.thfilter(c)
	return c:IsSetCard(0x15f) and not c:IsCode(83286340) and c:IsAbleToHand()
end
-- 检查怪兽是否为自己场上的地属性·战士族怪兽
function c83286340.check(c,tp)
	return c and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- 效果①的发动准备与合法性检测
function c83286340.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查进行战斗的怪兽中是否存在自己的地属性·战士族怪兽
	if chk==0 then return (c83286340.check(Duel.GetAttacker(),tp) or c83286340.check(Duel.GetAttackTarget(),tp))
		-- 检查卡组中是否存在可以加入手卡的「战吼斗士·福蒂亚」以外的「战吼」卡
		and Duel.IsExistingMatchingCard(c83286340.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己场上是否存在可以上升攻击力的「战吼」怪兽
		and Duel.IsExistingMatchingCard(c83286340.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤自己场上表侧表示且未被战斗破坏的「战吼」怪兽
function c83286340.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果①的处理：检索「战吼」卡，并使自己场上的「战吼」怪兽攻击力上升
function c83286340.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「战吼」卡
	local g=Duel.SelectMatchingCard(tp,c83286340.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功将选中的卡加入手卡
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查自己场上是否存在符合条件的「战吼」怪兽
		if Duel.IsExistingMatchingCard(c83286340.atkfilter,tp,LOCATION_MZONE,0,1,nil) then
			-- 中断当前效果，使后续的攻击力上升处理不与加入手卡同时处理
			Duel.BreakEffect()
			-- 获取自己场上所有符合条件的「战吼」怪兽
			local sg=Duel.GetMatchingGroup(c83286340.atkfilter,tp,LOCATION_MZONE,0,nil)
			-- 遍历这些怪兽
			for tc in aux.Next(sg) do
				-- 自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
				e1:SetValue(200)
				tc:RegisterEffect(e1)
			end
		end
	end
end
-- 检查是否是被对方的效果从自己的怪兽区域送去墓地
function c83286340.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 过滤手卡·卡组中5星以上的「战吼」怪兽
function c83286340.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsSetCard(0x15f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测
function c83286340.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在可以特殊召唤的5星以上「战吼」怪兽
		and Duel.IsExistingMatchingCard(c83286340.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息为从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果②的处理：从手卡·卡组特殊召唤1只5星以上的「战吼」怪兽
function c83286340.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的5星以上「战吼」怪兽
	local g=Duel.SelectMatchingCard(tp,c83286340.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
