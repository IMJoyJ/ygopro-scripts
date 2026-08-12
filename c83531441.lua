--彼岸の旅人 ダンテ
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，从自己卡组上面把最多3张卡送去墓地才能发动。这张卡的攻击力直到回合结束时上升因为这个效果发动而送去墓地的卡数量×500。
-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
-- ③：这张卡被送去墓地的场合，以自己墓地1张其他的「彼岸」卡为对象才能发动。那张卡加入手卡。
function c83531441.initial_effect(c)
	-- 添加XYZ召唤手续：3星怪兽×2
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，从自己卡组上面把最多3张卡送去墓地才能发动。这张卡的攻击力直到回合结束时上升因为这个效果发动而送去墓地的卡数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83531441,0))  --"攻守变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c83531441.atkcost)
	e1:SetOperation(c83531441.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c83531441.poscon)
	e2:SetOperation(c83531441.posop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以自己墓地1张其他的「彼岸」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83531441,1))  --"卡片回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c83531441.thtg)
	e3:SetOperation(c83531441.thop)
	c:RegisterEffect(e3)
end
-- ①号效果的COST：取除1个超量素材，并从卡组上面把最多3张卡送去墓地
function c83531441.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能作为COST将至少1张卡从卡组送去墓地，以及这张卡是否能取除至少1个超量素材
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	local ct={}
	for i=3,1,-1 do
		-- 检查玩家是否能作为COST将指定数量的卡从卡组送去墓地
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,i) then
			table.insert(ct,i)
		end
	end
	if #ct==1 then
		-- 当只能送去1张卡时，将卡组最上方1张卡作为COST送去墓地
		Duel.DiscardDeck(tp,ct[1],REASON_COST)
		e:SetLabel(1)
	else
		-- 提示玩家选择要送去墓地的卡片数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(83531441,2))  --"请选择要送去墓地的卡的数量"
		-- 让玩家选择要送去墓地的卡片数量（1到3之间）
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 将玩家选择数量的卡片从卡组最上方作为COST送去墓地
		Duel.DiscardDeck(tp,ac,REASON_COST)
		e:SetLabel(ac)
	end
end
-- ①号效果的效果处理：使这张卡的攻击力直到回合结束时上升送去墓地的卡数量×500
function c83531441.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=e:GetLabel()
		-- 这张卡的攻击力直到回合结束时上升因为这个效果发动而送去墓地的卡数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*500)
		c:RegisterEffect(e1)
	end
end
-- ②号效果的发动条件：这张卡进行过攻击
function c83531441.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- ②号效果的效果处理：在战斗阶段结束时将这张卡变成表侧守备表示
function c83531441.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡变成表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：自己墓地中「彼岸」卡片且可以加入手牌
function c83531441.filter(c)
	return c:IsSetCard(0xb1) and c:IsAbleToHand()
end
-- ③号效果的靶向/发动准备：选择自己墓地1张其他的「彼岸」卡为对象
function c83531441.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83531441.filter(chkc) end
	-- 检查自己墓地是否存在除自身以外的、满足条件的「彼岸」卡片
	if chk==0 then return Duel.IsExistingTarget(c83531441.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张其他的「彼岸」卡作为效果对象
	local g=Duel.SelectTarget(tp,c83531441.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置连锁信息：操作分类为加入手牌，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③号效果的效果处理：将作为对象的卡加入手牌
function c83531441.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
