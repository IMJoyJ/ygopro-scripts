--ダストンのモップ
-- 效果：
-- 装备怪兽不能解放，也不能作为融合·同调·超量召唤的素材。场上的这张卡被对方的卡的效果破坏送去墓地时，可以从卡组把1只名字带有「尘妖」的怪兽加入手卡。「尘妖的拖把」在自己场上只能有1张表侧表示存在。
function c24845628.initial_effect(c)
	c:SetUniqueOnField(1,0,24845628)
	-- 装备怪兽不能解放，也不能作为融合·同调·超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c24845628.target)
	e1:SetOperation(c24845628.operation)
	c:RegisterEffect(e1)
	-- 场上的这张卡被对方的卡的效果破坏送去墓地时，可以从卡组把1只名字带有「尘妖」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 「尘妖的拖把」在自己场上只能有1张表侧表示存在。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e5:SetValue(c24845628.fuslimit)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e7)
	-- 效果作用
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(24845628,0))  --"检索"
	e7:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCondition(c24845628.thcon)
	e7:SetTarget(c24845628.thtg)
	e7:SetOperation(c24845628.thop)
	c:RegisterEffect(e7)
end
-- 检索满足条件的卡片组
function c24845628.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 效果作用
function c24845628.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽进行装备
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果作用
function c24845628.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 效果作用
function c24845628.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，筛选名字带有「尘妖」的怪兽
function c24845628.filter(c)
	return c:IsSetCard(0x80) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用
function c24845628.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c24845628.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用
function c24845628.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡片加入手牌
	local g=Duel.SelectMatchingCard(tp,c24845628.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
