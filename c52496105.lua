--剣闘獣の闘器マニカ
-- 效果：
-- 名字带有「剑斗兽」的怪兽才能装备。只要有这张卡装备，装备怪兽不会被战斗破坏（伤害计算适用）。装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡。
function c52496105.initial_effect(c)
	-- 名字带有「剑斗兽」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c52496105.target)
	e1:SetOperation(c52496105.operation)
	c:RegisterEffect(e1)
	-- 只要有这张卡装备，装备怪兽不会被战斗破坏（伤害计算适用）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 名字带有「剑斗兽」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c52496105.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(52496105,0))  --"返回手牌"
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c52496105.retcon)
	e4:SetTarget(c52496105.rettg)
	e4:SetOperation(c52496105.retop)
	c:RegisterEffect(e4)
end
-- 作为装备限制值，判定候选怪兽是否卡名含有「剑斗兽」（0x1019），只有满足该种族字段的怪兽才能装备这张卡。
function c52496105.eqlimit(e,c)
	return c:IsSetCard(0x1019)
end
-- 筛选出场上的表侧表示且卡名含有「剑斗兽」的怪兽，作为这张装备卡的装备对象候选。
function c52496105.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 装备魔法卡发动时的取对象处理：检查场上是否存在符合条件的剑斗兽怪兽，存在则提示玩家选择1只作为装备对象，并登记装备处理信息。
function c52496105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52496105.filter(chkc) end
	-- 发动合法性检查：确认场上存在至少1只表侧表示且卡名含有「剑斗兽」的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c52496105.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家显示选择提示，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让发动玩家从自己或对方场上选择1只表侧表示且卡名含有「剑斗兽」的怪兽，并将其登记为这张卡的取对象。
	Duel.SelectTarget(tp,c52496105.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：效果分类为装备（CATEGORY_EQUIP），预定处理对象为这张装备卡本身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡和对象怪兽仍与效果关联且对象怪兽仍表侧表示，则将这张卡装备给该怪兽。
function c52496105.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给目标怪兽，完成装备。
		Duel.Equip(tp,c,tc)
	end
end
-- 诱发返回手牌效果的条件：这张卡因失去装备对象被送去墓地，且原来的装备对象位于卡组/额外卡组（即装备怪兽从自己场上回到了卡组）。
function c52496105.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 返回手牌效果的发动合法性与目标设定：确认这张装备卡能够加入手卡，若能则设置回手牌的处理信息。
function c52496105.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置本次连锁的操作信息：效果分类为回到手牌（CATEGORY_TOHAND），处理对象为这张装备卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍与效果关联，则将其返回持有者手卡，并向对方玩家展示这张卡以确认。
function c52496105.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张装备卡返回持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家确认这张回到了手卡的装备卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
