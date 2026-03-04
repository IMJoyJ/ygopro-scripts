--聖騎士ガラハド
-- 效果：
-- 这张卡只要在场上表侧表示存在，当作通常怪兽使用。只要这张卡有名字带有「圣剑」的装备魔法卡装备，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●选择自己墓地1只名字带有「圣骑士」的怪兽才能发动。选择的怪兽加入手卡，选自己场上1张名字带有「圣剑」的装备魔法卡破坏。「圣骑士 加拉哈德」的这个效果1回合只能使用1次。
function c13391185.initial_effect(c)
	-- 效果原文：这张卡只要在场上表侧表示存在，当作通常怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c13391185.eqcon1)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
	-- 效果原文：选择自己墓地1只名字带有「圣骑士」的怪兽才能发动。选择的怪兽加入手卡，选自己场上1张名字带有「圣剑」的装备魔法卡破坏。「圣骑士 加拉哈德」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13391185,0))  --"返回手牌"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,13391185)
	e3:SetCondition(c13391185.thcon)
	e3:SetTarget(c13391185.thtg)
	e3:SetOperation(c13391185.thop)
	c:RegisterEffect(e3)
end
-- 判断装备区是否没有名字带有「圣剑」的装备魔法卡
function c13391185.eqcon1(e)
	local eg=e:GetHandler():GetEquipGroup()
	return not eg or not eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 判断装备区是否有名字带有「圣剑」的装备魔法卡
function c13391185.eqcon2(e)
	local eg=e:GetHandler():GetEquipGroup()
	return eg and eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 效果发动的条件：装备区有名字带有「圣剑」的装备魔法卡
function c13391185.thcon(e,tp,eg,ep,ev,re,r,rp)
	return c13391185.eqcon2(e)
end
-- 过滤墓地里名字带有「圣骑士」的怪兽
function c13391185.thfilter(c)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标：选择墓地里名字带有「圣骑士」的怪兽
function c13391185.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13391185.thfilter(chkc) end
	-- 检查是否满足选择目标的条件：墓地存在名字带有「圣骑士」的怪兽
	if chk==0 then return Duel.IsExistingTarget(c13391185.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择目标：从墓地选择1只名字带有「圣骑士」的怪兽
	local g=Duel.SelectTarget(tp,c13391185.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤场上名字带有「圣剑」的装备魔法卡
function c13391185.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsType(TYPE_EQUIP)
end
-- 效果处理函数：执行将怪兽加入手牌并破坏装备魔法卡的操作
function c13391185.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然存在于场上并成功加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要破坏的装备魔法卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		-- 从场上选择1张名字带有「圣剑」的装备魔法卡
		local dg=Duel.SelectMatchingCard(tp,c13391185.desfilter,tp,LOCATION_SZONE,0,1,1,nil)
		-- 中断当前效果连锁，使后续处理视为错时点
		Duel.BreakEffect()
		-- 破坏选择的装备魔法卡
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
