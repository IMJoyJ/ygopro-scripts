--円盤闘技場セリオンズ・リング
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「兽带斗神」怪兽加入手卡。
-- ②：1回合1次，自己怪兽被战斗破坏的场合，可以作为代替从卡组把1张「兽带斗神」卡或者「无尽机关 银星系统」送去墓地。
-- ③：1回合1次，自己或者对方的怪兽被战斗破坏送去墓地时，以自己墓地1只「兽带斗神」怪兽为对象才能发动。那只怪兽加入手卡。
function c84792926.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「兽带斗神」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,84792926+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c84792926.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己怪兽被战斗破坏的场合，可以作为代替从卡组把1张「兽带斗神」卡或者「无尽机关 银星系统」送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c84792926.destg)
	e2:SetValue(c84792926.desvalue)
	e2:SetOperation(c84792926.desop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己或者对方的怪兽被战斗破坏送去墓地时，以自己墓地1只「兽带斗神」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84792926,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1)
	e3:SetTarget(c84792926.thtg)
	e3:SetOperation(c84792926.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组或墓地中可以加入手牌的「兽带斗神」怪兽
function c84792926.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:IsAbleToHand()
end
-- 作为这张卡的发动时的效果处理，可以从卡组把1只「兽带斗神」怪兽加入手卡
function c84792926.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「兽带斗神」怪兽
	local g=Duel.GetMatchingGroup(c84792926.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的怪兽，则询问玩家是否发动该效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(84792926,0)) then  --"是否从卡组把1只「兽带斗神」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤条件：自己场上因战斗被破坏的怪兽
function c84792926.dfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 过滤条件：卡组中可以送去墓地的「兽带斗神」卡或「无尽机关 银星系统」
function c84792926.repfilter(c)
	return (c:IsSetCard(0x179) or c:IsCode(21887075)) and c:IsAbleToGrave()
end
-- 代替破坏效果的发动条件判定：检查是否有自己怪兽被战破，且卡组中存在可送墓的代替卡
function c84792926.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c84792926.dfilter,1,nil,tp)
		-- 检查自己卡组中是否存在至少1张可以送去墓地的「兽带斗神」卡或「无尽机关 银星系统」
		and Duel.IsExistingMatchingCard(c84792926.repfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 询问玩家是否适用代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏的适用范围：自己控制的因战斗破坏的怪兽
function c84792926.desvalue(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_BATTLE)
end
-- 代替破坏的效果处理：从卡组选择1张「兽带斗神」卡或「无尽机关 银星系统」送去墓地
function c84792926.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c84792926.repfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡作为代替送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
end
-- 过滤条件：因战斗破坏送去墓地的怪兽
function c84792926.filter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 效果③的发动条件与对象选择：确认有怪兽被战破送墓，并选择自己墓地1只「兽带斗神」怪兽为对象
function c84792926.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c84792926.thfilter(chkc) end
	if chk==0 then return eg:IsExists(c84792926.filter,1,nil)
		-- 检查自己墓地是否存在至少1只可以作为效果对象的「兽带斗神」怪兽
		and Duel.IsExistingTarget(c84792926.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「兽带斗神」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c84792926.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的效果处理：将作为对象的墓地怪兽加入手牌
function c84792926.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
