--神鳴り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只雷族怪兽加入手卡。这张卡的发动后，直到下个回合的结束时，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤。
local s,id,o=GetID()
-- 注册该卡发动的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只雷族怪兽加入手卡。这张卡的发动后，直到下个回合的结束时，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检索条件过滤：过滤卡组中可以加入手牌的雷族怪兽
function s.thfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToHand()
end
-- 效果发动靶向：检查卡组是否存在可以检索的怪兽并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在可以加入手牌的雷族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计将卡组中的1张卡加入玩家手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1只雷族怪兽加入手牌，并注册直到下个回合结束时不能通常召唤该卡及同名怪兽的限制效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的雷族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 如果成功将所选怪兽加入手牌
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 给对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,tc)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			-- 这张卡的发动后，直到下个回合的结束时，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.sumlimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 给玩家注册不能通常召唤（表侧表示召唤）该怪兽及同名怪兽的效果
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_MSET)
			-- 给玩家注册不能通常召唤（里侧表示盖放）该怪兽及同名怪兽的效果
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 通常召唤限制条件：若召唤的卡片卡号与被检索卡片的卡号相同则无法召唤
function s.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
