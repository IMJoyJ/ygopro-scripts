--ワーム・ホープ
-- 效果：
-- 反转：被对方怪兽的攻击反转的场合，从自己卡组抽1张卡。此外，这张卡从场上送去墓地时，自己把1张手卡送去墓地。
function c11159464.initial_effect(c)
	-- 反转：被对方怪兽的攻击反转的场合，从自己卡组抽1张卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetTarget(c11159464.drtg)
	e1:SetOperation(c11159464.drop)
	c:RegisterEffect(e1)
	-- 此外，这张卡从场上送去墓地时，自己把1张手卡送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11159464,0))  --"把1张手牌送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c11159464.tgcon)
	e2:SetTarget(c11159464.tgtg)
	e2:SetOperation(c11159464.tgop)
	c:RegisterEffect(e2)
end
-- 反转效果的Target函数：若被对方怪兽攻击反转，则设置抽卡的操作信息
function c11159464.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 判断是否在伤害步骤且自身是被攻击的怪兽（即被攻击反转）
	if Duel.GetCurrentPhase()==PHASE_DAMAGE and e:GetHandler()==Duel.GetAttackTarget() then
		-- 设置操作信息：玩家从卡组抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 反转效果的Operation函数：若被对方怪兽攻击反转，则执行抽卡效果
function c11159464.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在伤害步骤且自身是被攻击的怪兽（即被攻击反转）
	if Duel.GetCurrentPhase()==PHASE_DAMAGE and e:GetHandler()==Duel.GetAttackTarget() then
		-- 玩家因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 效果发动条件过滤：这张卡此前的位置是否在场上
function c11159464.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 送去墓地效果的Target函数：设置将手卡送去墓地的操作信息
function c11159464.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自己手卡的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 送去墓地效果的Operation函数：让玩家选择手牌中的1张卡送去墓地
function c11159464.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己手牌中的1张卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
