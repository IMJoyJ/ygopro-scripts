--極星宝ドラウプニル
-- 效果：
-- 名字带有「极神」或者「极星」的怪兽才能装备。装备怪兽的攻击力上升800。场上表侧表示存在的这张卡被卡的效果破坏的场合，可以从自己卡组把1张名字带有「极星宝」的卡加入手卡。
function c55154048.initial_effect(c)
	-- 名字带有「极神」或者「极星」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c55154048.target)
	e1:SetOperation(c55154048.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 名字带有「极神」或者「极星」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c55154048.eqlimit)
	c:RegisterEffect(e3)
	-- 场上表侧表示存在的这张卡被卡的效果破坏的场合，可以从自己卡组把1张名字带有「极星宝」的卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55154048,0))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c55154048.thcon)
	e4:SetTarget(c55154048.thtg)
	e4:SetOperation(c55154048.thop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给名字带有「极神」或「极星」的怪兽
function c55154048.eqlimit(e,c)
	return c:IsSetCard(0x42,0x4b)
end
-- 过滤条件：场上表侧表示的名字带有「极神」或「极星」的怪兽
function c55154048.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x42,0x4b)
end
-- 装备魔法卡发动时的效果目标选择与处理
function c55154048.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c55154048.filter(chkc) end
	-- 检查场上是否存在可以装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c55154048.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息：请选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c55154048.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作，操作对象为这张卡本身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的效果处理：将这张卡装备给目标怪兽
function c55154048.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 检索效果的发动条件：场上表侧表示存在的这张卡被卡的效果破坏
function c55154048.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and bit.band(e:GetHandler():GetReason(),0x41)==0x41
end
-- 过滤条件：卡组中名字带有「极星宝」且可以加入手卡的卡
function c55154048.thfilter(c)
	return c:IsSetCard(0x5042) and c:IsAbleToHand()
end
-- 检索效果的发动准备与目标检查
function c55154048.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在可以检索的「极星宝」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c55154048.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体处理：从卡组选择1张「极星宝」卡片加入手卡
function c55154048.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的「极星宝」卡片
	local g=Duel.SelectMatchingCard(tp,c55154048.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
