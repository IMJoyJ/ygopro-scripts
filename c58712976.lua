--ヘルフレイムゴースト
-- 效果：
-- 炎族4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到对方的结束阶段时上升500。此外，攻击力2500以上的这张卡被破坏时，选择双方墓地的怪兽合计3只从游戏中除外。
function c58712976.initial_effect(c)
	-- 设置XYZ召唤手续：炎族4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到对方的结束阶段时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(58712976,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c58712976.cost)
	e1:SetOperation(c58712976.operation)
	c:RegisterEffect(e1)
	-- 此外，攻击力2500以上的这张卡被破坏时，选择双方墓地的怪兽合计3只从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58712976,1))  --"除外"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c58712976.rmcon)
	e2:SetTarget(c58712976.rmtg)
	e2:SetOperation(c58712976.rmop)
	c:RegisterEffect(e2)
end
-- 起动效果的代价：检查并取除这张卡的1个超量素材
function c58712976.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 起动效果的处理：若这张卡在场上表侧表示存在，则使其攻击力上升500，直到对方的结束阶段
function c58712976.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到对方的结束阶段时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
-- 被破坏时效果的发动条件：这张卡在场上最后存在的攻击力在2500以上
function c58712976.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousAttackOnField()>=2500
end
-- 过滤条件：墓地的怪兽卡且可以被除外
function c58712976.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 被破坏时效果的靶向处理：选择双方墓地合计3只怪兽作为对象，并设置除外操作信息
function c58712976.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c58712976.filter(chkc) end
	if chk==0 then return true end
	-- 判断双方墓地是否存在合计3只满足条件的怪兽
	if Duel.IsExistingTarget(c58712976.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,nil) then
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择双方墓地合计3只满足条件的怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c58712976.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,3,nil)
		-- 设置效果处理信息：将选中的3张卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,3,PLAYER_ALL,LOCATION_GRAVE)
	end
end
-- 被破坏时效果的实际处理：将作为效果对象的3只怪兽除外
function c58712976.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local rg=g:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 将仍存在于墓地且与效果相关的对象卡片表侧表示除外
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
