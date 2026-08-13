--陽炎獣 バジリコック
-- 效果：
-- 炎属性6星怪兽×2只以上（最多5只）
-- 1回合1次，把这张卡1个超量素材取除才能发动。选择对方的场上·墓地1只怪兽从游戏中除外。此外，这张卡持有的超量素材数量让这张卡得到以下效果。
-- ●3个以上：这张卡的攻击力·守备力上升这张卡的超量素材数量×200的数值。
-- ●4个以上：这张卡不会成为对方的卡的效果的对象。
-- ●5个：这张卡不会被卡的效果破坏。
function c23776077.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以炎属性6星怪兽2只以上（最多5只）为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),6,2,nil,nil,5)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。选择对方的场上·墓地1只怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23776077,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c23776077.rmcost)
	e1:SetTarget(c23776077.rmtg)
	e1:SetOperation(c23776077.rmop)
	c:RegisterEffect(e1)
	-- ●3个以上：这张卡的攻击力·守备力上升这张卡的超量素材数量×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c23776077.adcon)
	e2:SetValue(c23776077.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ●4个以上：这张卡不会成为对方的卡的效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c23776077.tgcon)
	-- 设置该效果的价值函数，使这张卡不会成为对方的卡的效果的对象。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ●5个：这张卡不会被卡的效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c23776077.indcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 支付发动代价：先检查能否从这张卡上取除1个超量素材，若可以则实际取除1个超量素材作为发动cost。
function c23776077.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义选择过滤条件：对象必须是怪兽，并且可以被除外（不受到不能除外等限制）。
function c23776077.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 发动时的取对象处理：确认对象合法性，提示玩家从对方场上·墓地选择1只怪兽，优先选择场上的怪兽；并根据对象所在位置（墓地/场上）登记对应的除外操作信息。
function c23776077.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c23776077.rmfilter(chkc) end
	-- 发动条件检查：确认对方场上或墓地存在至少1张满足条件的怪兽（且能被除外）可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c23776077.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 发送选择提示，让玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 调用选择辅助函数从对方场上·墓地选择1张符合条件的怪兽作为对象；若场上合法目标不足则从墓地补足，并将所选卡片设为连锁对象。
	local g=aux.SelectTargetFromFieldFirst(tp,c23776077.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 登记操作信息：对象位于墓地时，标记为将对方墓地的1张怪兽除外，共1张，供连锁判定使用。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	else
		-- 登记操作信息：对象位于场上时，标记为将对方场上的1张怪兽除外，共1张，供连锁判定使用。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
-- 效果处理：获取连锁对象，若对象仍与效果关联，则将其除外。
function c23776077.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽从游戏中表侧表示除外（除外原因：效果）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 攻击力·守备力上升效果的适用条件：这张卡的超量素材数量为3个以上。
function c23776077.adcon(e)
	return e:GetHandler():GetOverlayCount()>=3
end
-- 计算攻击力·守备力的上升数值：超量素材数量×200。
function c23776077.adval(e,c)
	return e:GetHandler():GetOverlayCount()*200
end
-- 不会成为对方效果对象的效果的适用条件：超量素材数量为4个以上。
function c23776077.tgcon(e)
	return e:GetHandler():GetOverlayCount()>=4
end
-- 不会被效果破坏的效果的适用条件：超量素材数量正好为5个。
function c23776077.indcon(e)
	return e:GetHandler():GetOverlayCount()==5
end
