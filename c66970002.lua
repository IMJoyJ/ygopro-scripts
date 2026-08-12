--CNo.39 希望皇ホープレイV
-- 效果：
-- 5星怪兽×3
-- ①：这张卡被对方破坏时，以自己墓地1只超量怪兽为对象才能发动。那只怪兽回到额外卡组。
-- ②：这张卡有「希望皇 霍普」怪兽在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，把表侧表示怪兽破坏的场合，给与对方那个攻击力数值的伤害。
function c66970002.initial_effect(c)
	-- 设置该卡超量召唤的素材条件为5星怪兽3只
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：这张卡被对方破坏时，以自己墓地1只超量怪兽为对象才能发动。那只怪兽回到额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66970002,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c66970002.tdcon)
	e1:SetTarget(c66970002.tdtg)
	e1:SetOperation(c66970002.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「希望皇 霍普」怪兽在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，把表侧表示怪兽破坏的场合，给与对方那个攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetDescription(aux.Stringid(66970002,1))  --"破坏并伤害"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c66970002.descon)
	e2:SetCost(c66970002.descost)
	e2:SetTarget(c66970002.destg)
	e2:SetOperation(c66970002.desop)
	c:RegisterEffect(e2)
end
-- 设置该怪兽的“No.”数值为39
aux.xyz_number[66970002]=39
-- 效果①的发动条件：由对方玩家的操作导致该卡被破坏
function c66970002.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤自己墓地中可以回到卡组的超量怪兽
function c66970002.tdfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsAbleToDeck()
end
-- 效果①的发动准备阶段，确认并选择自己墓地1只超量怪兽作为对象，并设置效果分类为回额外卡组
function c66970002.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c66970002.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少1只可以回到额外卡组的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c66970002.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自己墓地1只满足条件的超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66970002.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的1张卡送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 效果①的效果处理阶段，将作为对象的怪兽送回额外卡组
function c66970002.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者的额外卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 效果②的发动条件：检查该卡是否有「希望皇 霍普」怪兽作为超量素材
function c66970002.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x107f)
end
-- 效果②的发动代价：取除该卡的1个超量素材
function c66970002.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动准备阶段，选择对方场上1只怪兽作为对象，并设置破坏与伤害的操作信息
function c66970002.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为破坏选中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息为给与对方相当于被破坏怪兽攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
-- 效果②的效果处理阶段，破坏作为对象的怪兽，并给与对方相当于其攻击力数值的伤害
function c66970002.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		local atk=tc:GetAttack()
		if atk<0 or tc:IsFacedown() then atk=0 end
		-- 尝试破坏作为对象的怪兽，并判断是否破坏成功
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方相当于被破坏怪兽攻击力数值的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
