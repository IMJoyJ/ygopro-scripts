--白き森のリゼット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。这张卡特殊召唤。那之后，从卡组把「白森林的莉泽特」以外的1只「白森林」怪兽加入手卡。
-- ②：这张卡在墓地存在的状态，对方回合自己场上有魔法师族·光属性调整特殊召唤的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。这张卡特殊召唤。那之后，从卡组把「白森林的莉泽特」以外的1只「白森林」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，对方回合自己场上有魔法师族·光属性调整特殊召唤的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足送去墓地代价的魔法·陷阱卡，并确保有怪兽区域空位
function s.cfilter(c,tp)
	return c:IsAbleToGraveAsCost()
		-- 检查卡片是否为魔法·陷阱卡，并确保该卡送去墓地后有可用的怪兽区域
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的代价处理：从手卡·场上将1张魔法·陷阱卡送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可作为代价送去墓地的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或场上选择1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler(),tp)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤卡组中「白森林的莉泽特」以外的「白森林」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1b1) and not c:IsCode(id) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
end
-- 效果①的发动准备与检查：检查自身能否特殊召唤，以及卡组是否存在可检索的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在可加入手卡的「白森林」怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置从卡组将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：特殊召唤自身，那之后从卡组检索1只「白森林」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否能特殊召唤成功，且卡组中仍有可检索的怪兽，且自身在怪兽区域存在
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsLocation(LOCATION_MZONE) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只满足条件的「白森林」怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的检索处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤自己场上表侧表示的魔法师族·光属性调整怪兽
function s.cfilter2(c,tp)
	return c:IsType(TYPE_TUNER) and c:IsRace(RACE_SPELLCASTER)
		and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup() and c:IsControler(tp)
end
-- 效果②的发动条件：对方回合自己场上有魔法师族·光属性调整特殊召唤的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特殊召唤的怪兽中是否存在满足条件的怪兽，且当前为对方回合
	return eg:IsExists(s.cfilter2,1,nil,tp) and Duel.GetTurnPlayer()~=tp
end
-- 效果②的发动准备与检查：检查自身能否加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将自身从墓地加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将墓地的这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
