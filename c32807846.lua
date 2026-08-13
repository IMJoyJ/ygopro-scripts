--増援
-- 效果：
-- ①：从卡组把1只4星以下的战士族怪兽加入手卡。
function c32807846.initial_effect(c)
	-- ①：从卡组把1只4星以下的战士族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32807846.target)
	e1:SetOperation(c32807846.activate)
	c:RegisterEffect(e1)
end
-- 定义检索过滤条件：卡必须为等级4以下、种族为战士族，且能被效果加入手卡。
function c32807846.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 发动时的目标处理：chk==0时检查卡组中是否存在满足条件的怪兽；若存在则设置操作信息，表示本次效果为从卡组将1张卡加入手牌。
function c32807846.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若chk==0，判定卡组中是否存在至少1张满足c32807846.filter的怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c32807846.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将本次连锁的效果处理信息标记为CATEGORY_TOHAND，预定从卡组将1张卡加入手牌，供后续效果联动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：提示玩家选择要加入手牌的卡，从卡组选出1张满足条件的怪兽加入手牌，并向对方展示。
function c32807846.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp发出选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己的卡组中选出1张满足c32807846.filter的卡（已确认至少存在1张）。
	local g=Duel.SelectMatchingCard(tp,c32807846.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌，移动原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
