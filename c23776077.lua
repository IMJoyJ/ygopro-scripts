--陽炎獣 バジリコック
-- 效果：
-- 炎属性6星怪兽×2只以上（最多5只）
-- 1回合1次，把这张卡1个超量素材取除才能发动。选择对方的场上·墓地1只怪兽从游戏中除外。此外，这张卡持有的超量素材数量让这张卡得到以下效果。
-- ●3个以上：这张卡的攻击力·守备力上升这张卡的超量素材数量×200的数值。
-- ●4个以上：这张卡不会成为对方的卡的效果的对象。
-- ●5个：这张卡不会被卡的效果破坏。
function c23776077.initial_effect(c)
	-- 添加XYZ召唤手续，要求使用1只以上炎属性怪兽作为素材进行召唤，最少需要2只，最多5只
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
	-- 设置效果值为aux.tgoval函数，用于判断是否成为对方效果的对象
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
-- 支付1个超量素材作为cost，从自己场上移除1个超量素材
function c23776077.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选可以除外的怪兽，必须是怪兽卡且可以被除外
function c23776077.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 设置效果目标，选择对方场上或墓地的1只怪兽作为目标
function c23776077.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c23776077.rmfilter(chkc) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c23776077.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上选择目标，若场上无足够目标则从墓地选择
	local g=aux.SelectTargetFromFieldFirst(tp,c23776077.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，指定要除外的卡来自对方墓地
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	else
		-- 设置操作信息，指定要除外的卡来自对方场上
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
-- 执行效果，将目标怪兽从游戏中除外
function c23776077.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断当前超量素材数量是否大于等于3
function c23776077.adcon(e)
	return e:GetHandler():GetOverlayCount()>=3
end
-- 设置攻击力增加量为当前超量素材数量乘以200
function c23776077.adval(e,c)
	return e:GetHandler():GetOverlayCount()*200
end
-- 判断当前超量素材数量是否大于等于4
function c23776077.tgcon(e)
	return e:GetHandler():GetOverlayCount()>=4
end
-- 判断当前超量素材数量是否等于5
function c23776077.indcon(e)
	return e:GetHandler():GetOverlayCount()==5
end
