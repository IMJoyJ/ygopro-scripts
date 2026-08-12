--剣闘獣の闘器デーモンズシールド
-- 效果：
-- 名字带有「剑斗兽」的怪兽才能装备。装备怪兽被破坏的场合，作为代替把这张卡破坏。装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡。
function c8730435.initial_effect(c)
	-- 名字带有「剑斗兽」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c8730435.target)
	e1:SetOperation(c8730435.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽被破坏的场合，作为代替把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 名字带有「剑斗兽」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c8730435.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(8730435,0))  --"返回手牌"
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c8730435.retcon)
	e4:SetTarget(c8730435.rettg)
	e4:SetOperation(c8730435.retop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给名字带有「剑斗兽」的怪兽
function c8730435.eqlimit(e,c)
	return c:IsSetCard(0x1019)
end
-- 过滤条件：场上表侧表示的名字带有「剑斗兽」的怪兽
function c8730435.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 装备魔法卡发动时的效果处理：选择场上1只表侧表示的名字带有「剑斗兽」的怪兽为对象
function c8730435.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c8730435.filter(chkc) end
	-- 检查场上是否存在可以装备的合法对象
	if chk==0 then return Duel.IsExistingTarget(c8730435.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的名字带有「剑斗兽」的怪兽作为装备对象
	Duel.SelectTarget(tp,c8730435.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此效果包含装备卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理：将此卡装备给目标怪兽
function c8730435.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 诱发效果的发动条件：装备怪兽因回到卡组或额外卡组导致此卡失去装备对象而送去墓地
function c8730435.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 诱发效果的靶向处理：确认此卡是否能加入手卡，并设置操作信息
function c8730435.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：此效果包含将这张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 诱发效果的实际处理：将这张卡加入手卡并给对方确认
function c8730435.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果将这张卡加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
