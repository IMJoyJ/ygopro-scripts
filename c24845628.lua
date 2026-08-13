--ダストンのモップ
-- 效果：
-- 装备怪兽不能解放，也不能作为融合·同调·超量召唤的素材。场上的这张卡被对方的卡的效果破坏送去墓地时，可以从卡组把1只名字带有「尘妖」的怪兽加入手卡。「尘妖的拖把」在自己场上只能有1张表侧表示存在。
function c24845628.initial_effect(c)
	c:SetUniqueOnField(1,0,24845628)
	-- 装备怪兽（这张卡发动后装备给怪兽，对应原文中“装备怪兽”的前提）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c24845628.target)
	e1:SetOperation(c24845628.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽（作为装备卡时，只能装备给怪兽，对应原文中“装备怪兽”的限定）。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 装备怪兽不能解放（作为上级召唤的解放）。
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
	-- 场上的这张卡被对方的卡的效果破坏送去墓地时，可以从卡组把1只名字带有「尘妖」的怪兽加入手卡。
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
-- 融合素材限制的判断函数：仅当即将进行的召唤方式是融合召唤时，不允许这张卡的装备怪兽作为融合素材。
function c24845628.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 装备魔法发动时的取对象处理：以场上1只表侧表示怪兽为装备对象，并设置将这张卡装备的相关操作信息。
function c24845628.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动时点检查：场上是否存在至少1只表侧表示怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 为玩家显示选择装备对象的提示信息（“请选择要装备的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方怪兽区选择1只表侧表示怪兽作为这张卡装备的对象（取对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将进行装备卡装备，被装备的是这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的装备操作：确认这张卡和目标怪兽仍与效果相关且目标表侧表示后，将这张卡作为装备卡装备给目标怪兽。
function c24845628.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备魔法卡，由tp玩家装备到目标怪兽的怪兽区。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检索效果的发动条件：这张卡因对方的卡的效果被破坏并送去墓地，且破坏前在自己场上（由自己控制）存在。
function c24845628.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索用过滤函数：卡组中1只名字带有「尘妖」的怪兽且能被加入手卡。
function c24845628.filter(c)
	return c:IsSetCard(0x80) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动时点处理：确认卡组中存在符合条件的「尘妖」怪兽，并设置操作信息为从卡组将1张加入手卡。
function c24845628.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：卡组中是否存在至少1只满足检索条件的「尘妖」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24845628.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时，卡组中的1张卡将被加入手卡（目标位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：选择卡组中1只「尘妖」怪兽加入手卡，并展示给对方玩家确认。
function c24845628.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家显示选择要加入手牌的卡片的提示信息（“请选择要加入手牌的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的「尘妖」怪兽。
	local g=Duel.SelectMatchingCard(tp,c24845628.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「尘妖」怪兽加入其持有者的手卡（原因为效果）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的「尘妖」怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
