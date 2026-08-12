--赫聖の相剣
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有同调怪兽存在的场合，以自己或者对方的场上·墓地1张卡为对象才能发动。那张卡除外。
-- ②：对方场上有仪式·融合·同调·超量·连接怪兽的其中任意种存在的场合，从自己墓地把1只同调怪兽除外才能发动。墓地的这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己场上有同调怪兽存在的场合，以自己或者对方的场上·墓地1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方场上有仪式·融合·同调·超量·连接怪兽的其中任意种存在的场合，从自己墓地把1只同调怪兽除外才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的同调怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- ①号效果的发动条件：自己场上有同调怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的同调怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①号效果的对象选择与效果处理准备
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsAbleToRemove() and chkc~=c end
	-- 在发动阶段，检查自己或对方的场上·墓地是否存在可以除外的卡（排除这张卡自身）
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上选择，其次从墓地选择1张可以除外的卡作为对象
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,c)
	-- 设置操作信息：除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①号效果的效果处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡在效果处理时仍存在，则将其表侧表示除外
	if tc and tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end
-- 过滤条件：表侧表示的仪式、融合、同调、超量或连接怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- ②号效果的发动条件：对方场上有仪式·融合·同调·超量·连接怪兽存在
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在表侧表示的仪式、融合、同调、超量或连接怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤条件：墓地的同调怪兽且能作为代价除外
function s.rfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
end
-- ②号效果的发动代价处理
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在可以作为代价除外的同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只同调怪兽
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②号效果的目标检查与效果处理准备
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息：将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②号效果的效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡在效果处理时仍存在，则将其加入手卡
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
