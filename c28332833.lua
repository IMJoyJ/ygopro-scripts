--フレムベル・パウン
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组选择1只守备力200的怪兽加入手卡。
function c28332833.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组选择1只守备力200的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28332833,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c28332833.thcon)
	e1:SetTarget(c28332833.thtg)
	e1:SetOperation(c28332833.thop)
	c:RegisterEffect(e1)
end
-- 检查触发效果的条件：卡片在墓地且因战斗破坏被送去墓地
function c28332833.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：选择守备力为200且可以加入手牌的怪兽
function c28332833.filter(c)
	return c:IsDefense(200) and c:IsAbleToHand()
end
-- 设置效果的目标：从卡组检索1只守备力200的怪兽加入手牌
function c28332833.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组中是否存在至少1张守备力为200且可以加入手牌的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28332833.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：提示选择并执行将符合条件的怪兽加入手牌
function c28332833.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c28332833.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
