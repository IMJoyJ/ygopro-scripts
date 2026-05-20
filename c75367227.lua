--ゴーストリック・アルカード
-- 效果：
-- 3星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方不能选择其他的「鬼计」怪兽以及里侧守备表示怪兽作为攻击对象。
-- ②：把这张卡1个超量素材取除，以对方场上盖放的1张卡为对象才能发动。那张盖放的对方的卡破坏。
-- ③：这张卡被送去墓地的场合，以这张卡以外的自己墓地1张「鬼计」卡为对象才能发动。那张卡加入手卡。
function c75367227.initial_effect(c)
	-- 设置XYZ召唤手续：需要2只3星怪兽。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，对方不能选择其他的「鬼计」怪兽以及里侧守备表示怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c75367227.tg)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除，以对方场上盖放的1张卡为对象才能发动。那张盖放的对方的卡破坏。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(75367227,0))  --"盖卡破坏"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,75367227)
	e2:SetCost(c75367227.descost)
	e2:SetTarget(c75367227.destg)
	e2:SetOperation(c75367227.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以这张卡以外的自己墓地1张「鬼计」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetDescription(aux.Stringid(75367227,1))  --"加入手卡"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c75367227.thtg)
	e3:SetOperation(c75367227.thop)
	c:RegisterEffect(e3)
end
-- 攻击目标限制：不能选择自身以外的里侧表示怪兽或「鬼计」怪兽作为攻击对象。
function c75367227.tg(e,c)
	return c~=e:GetHandler() and (c:IsFacedown() or c:IsSetCard(0x8d))
end
-- 效果②的发动代价：取除这张卡的1个超量素材。
function c75367227.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：里侧表示的卡。
function c75367227.desfilter(c)
	return c:IsFacedown()
end
-- 效果②的目标选择：以对方场上盖放的1张卡为对象。
function c75367227.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c75367227.desfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的盖放的卡。
	if chk==0 then return Duel.IsExistingTarget(c75367227.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张盖放的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c75367227.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：包含破坏分类，目标为选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：破坏选择的盖放的卡。
function c75367227.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤条件：墓地中可以加入手牌的「鬼计」卡。
function c75367227.filter(c)
	return c:IsSetCard(0x8d) and c:IsAbleToHand()
end
-- 效果③的目标选择：以自己墓地1张「鬼计」卡为对象。
function c75367227.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c75367227.filter(chkc) end
	-- 检查自己墓地是否存在除自身以外可以加入手牌的「鬼计」卡。
	if chk==0 then return Duel.IsExistingTarget(c75367227.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地中1张除自身以外的「鬼计」卡作为效果对象。
	local g=Duel.SelectTarget(tp,c75367227.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置操作信息：包含加入手牌分类，目标为选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的效果处理：将选择的墓地中的卡加入手牌并给对方确认。
function c75367227.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
