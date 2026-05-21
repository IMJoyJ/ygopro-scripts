--影霊衣の術士 シュリット
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「影灵衣」仪式怪兽1只仪式召唤的场合，可以由这1张卡作为仪式召唤需要的等级数值的解放使用。
-- ②：这张卡被效果解放的场合才能发动。从卡组把1只战士族「影灵衣」仪式怪兽加入手卡。
function c90307777.initial_effect(c)
	-- ①：「影灵衣」仪式怪兽1只仪式召唤的场合，可以由这1张卡作为仪式召唤需要的等级数值的解放使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(c90307777.rlevel)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被效果解放的场合才能发动。从卡组把1只战士族「影灵衣」仪式怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90307777,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,90307777)
	e2:SetCondition(c90307777.thcon)
	e2:SetTarget(c90307777.thtg)
	e2:SetOperation(c90307777.thop)
	c:RegisterEffect(e2)
end
-- 仪式解放等级判定函数：若用于「影灵衣」仪式怪兽的仪式召唤，则可以作为该怪兽等级数值的解放使用。
function c90307777.rlevel(e,c)
	-- 获取此卡在系统安全阈值内的等级数值。
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsSetCard(0xb4) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 发动条件判定：这张卡被效果解放的场合。
function c90307777.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 过滤条件：卡组中战士族「影灵衣」仪式怪兽且能加入手牌。
function c90307777.filter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_RITUAL) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果发动阶段：检查卡组中是否存在符合条件的怪兽，并设置将卡加入手牌的操作信息。
function c90307777.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c90307777.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：从卡组选择1只满足条件的怪兽加入手牌，并给对方确认。
function c90307777.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c90307777.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
