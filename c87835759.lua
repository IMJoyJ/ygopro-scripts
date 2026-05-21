--創世の竜騎士
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，这张卡的等级在对方回合内上升4星。
-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只7·8星的龙族怪兽送去墓地。
-- ③：把1张手卡送去墓地，以自己墓地1只7·8星的龙族怪兽为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。
function c87835759.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡的等级在对方回合内上升4星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetCondition(c87835759.lvcon)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只7·8星的龙族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87835759,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为自身战斗破坏对方怪兽并送去墓地
	e2:SetCondition(aux.bdogcon)
	e2:SetTarget(c87835759.tgtg)
	e2:SetOperation(c87835759.tgop)
	c:RegisterEffect(e2)
	-- ③：把1张手卡送去墓地，以自己墓地1只7·8星的龙族怪兽为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87835759,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,87835759)
	e3:SetCost(c87835759.spcost)
	e3:SetTarget(c87835759.sptg)
	e3:SetOperation(c87835759.spop)
	c:RegisterEffect(e3)
end
-- 等级上升效果的条件函数
function c87835759.lvcon(e)
	-- 判定当前回合玩家是否不是自身控制者（即对方回合）
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 过滤卡组中满足条件的7·8星龙族怪兽
function c87835759.tgfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and c:IsAbleToGrave()
end
-- 效果②的发动准备（Target阶段），检查卡组中是否存在符合条件的卡并设置送去墓地的操作信息
function c87835759.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在至少1只7·8星的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87835759.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为“从卡组将1张卡送去墓地”
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation阶段），从卡组选择1只7·8星龙族怪兽送去墓地
function c87835759.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 过滤并让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c87835759.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果③的发动代价（Cost阶段），将1张手牌送去墓地
function c87835759.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定手牌中是否存在可以作为Cost送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择1张手牌作为Cost送去墓地
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤墓地中满足特殊召唤条件的7·8星龙族怪兽
function c87835759.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备（Target阶段），检查自身是否能送去墓地、怪兽区域是否有空位、墓地是否有可特召的龙族怪兽，并选择对象
function c87835759.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c87835759.spfilter(chkc,e,tp) end
	-- 判定自身送去墓地后是否有可用的怪兽区域空位，且自身是否能送去墓地
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and e:GetHandler():IsAbleToGrave()
		-- 判定自己墓地是否存在可以作为效果对象的7·8星龙族怪兽
		and Duel.IsExistingTarget(c87835759.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的7·8星龙族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c87835759.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息为“将自身送去墓地”
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 设置连锁处理的操作信息为“将选择的对象特殊召唤”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的效果处理（Operation阶段），将自身送去墓地，并将作为对象的怪兽特殊召唤
function c87835759.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定自身是否仍与效果相关，并成功将自身送去墓地
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 获取作为效果对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
