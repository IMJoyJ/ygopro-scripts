--ドラグニティ－クイリヌス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「龙骑兵团」魔法·陷阱卡加入手卡。
-- ②：只要这张卡有装备卡装备，自己的「龙骑兵团」怪兽不会被战斗破坏。
-- ③：以自己场上1张其他的「龙骑兵团」怪兽卡为对象才能发动。那张卡回到手卡·额外卡组。那之后，可以从手卡把1只「龙骑兵团」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①召唤·特召检索魔陷、②有装备卡时己方龙骑兵团怪兽战破抗性、③弹场上其他龙骑兵团怪兽回手/额外并特召手牌龙骑兵团怪兽的效果。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「龙骑兵团」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡有装备卡装备，自己的「龙骑兵团」怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置战破抗性效果的影响对象为「龙骑兵团」怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x29))
	e3:SetCondition(s.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：以自己场上1张其他的「龙骑兵团」怪兽卡为对象才能发动。那张卡回到手卡·额外卡组。那之后，可以从手卡把1只「龙骑兵团」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"回到手卡·额外"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.bstg)
	e4:SetOperation(s.bsop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中「龙骑兵团」魔法·陷阱卡且能加入手牌的卡片。
function s.thfilter(c)
	return c:IsSetCard(0x29) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动准备（Target），检查卡组中是否存在可检索的卡并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「龙骑兵团」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示该效果会将卡组中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理（Operation），从卡组选择1张「龙骑兵团」魔法·陷阱卡加入手牌并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足条件的「龙骑兵团」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的适用条件，自身装备卡数量大于0（即有装备卡装备）。
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipCount()>0
end
-- 过滤场上表侧表示的「龙骑兵团」怪兽卡（包含原本是怪兽的魔法卡，如装备状态），且能回到手牌或额外卡组。
function s.bfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and (c:GetOriginalType()&TYPE_MONSTER)~=0
		and (c:IsAbleToHand() or c:IsAbleToExtra())
end
-- ③效果的发动准备（Target），选择场上1张其他的「龙骑兵团」怪兽卡作为对象，并根据其去向设置相应的操作信息。
function s.bstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.bfilter(chkc) and chkc~=c end
	-- 检查场上是否存在除自身以外的、满足条件的「龙骑兵团」怪兽卡。
	if chk==0 then return Duel.IsExistingTarget(s.bfilter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1张除自身以外的、满足条件的「龙骑兵团」怪兽卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.bfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	local tc=g:GetFirst()
	if tc:IsAbleToExtra() then
		-- 若对象卡是额外卡组怪兽，设置连锁操作信息为将该卡送回额外卡组。
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	else
		-- 若对象卡不是额外卡组怪兽，设置连锁操作信息为将该卡送回手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 过滤手牌中可以特殊召唤的「龙骑兵团」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的处理（Operation），将对象卡送回手牌或额外卡组，之后可选择是否从手牌特殊召唤1只「龙骑兵团」怪兽。
function s.bsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的对象卡。
	local tg=Duel.GetTargetsRelateToChain()
	-- 如果对象卡存在且成功因效果送回手牌（或额外卡组）。
	if tg:GetCount()>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)>0
		and tg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_EXTRA) then
		-- 获取手牌中满足特殊召唤条件的「龙骑兵团」怪兽。
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 若手牌有可特召怪兽、怪兽区有空位，且玩家选择进行特殊召唤。
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理与回手牌不视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			if tg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
				-- 若有卡片回到了手牌，则洗切玩家的手牌。
				Duel.ShuffleHand(tp)
			end
			-- 将选择的「龙骑兵团」怪兽以表侧表示特殊召唤到场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
