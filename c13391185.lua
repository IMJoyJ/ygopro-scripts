--聖騎士ガラハド
-- 效果：
-- 这张卡只要在场上表侧表示存在，当作通常怪兽使用。只要这张卡有名字带有「圣剑」的装备魔法卡装备，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●选择自己墓地1只名字带有「圣骑士」的怪兽才能发动。选择的怪兽加入手卡，选自己场上1张名字带有「圣剑」的装备魔法卡破坏。「圣骑士 加拉哈德」的这个效果1回合只能使用1次。
function c13391185.initial_effect(c)
	-- 这张卡只要在场上表侧表示存在，当作通常怪兽使用。
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
	-- ●选择自己墓地1只名字带有「圣骑士」的怪兽才能发动。选择的怪兽加入手卡，选自己场上1张名字带有「圣剑」的装备魔法卡破坏。「圣骑士 加拉哈德」的这个效果1回合只能使用1次。
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
-- 判断这张卡没有装备名字带有「圣剑」的装备魔法卡（没有装备卡或装备卡中不含「圣剑」），用于让这张卡在未装备「圣剑」时当作通常怪兽使用。
function c13391185.eqcon1(e)
	local eg=e:GetHandler():GetEquipGroup()
	return not eg or not eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 判断这张卡是否装备有名字带有「圣剑」的装备魔法卡，作为这张卡变成效果怪兽并发动效果的判定条件。
function c13391185.eqcon2(e)
	local eg=e:GetHandler():GetEquipGroup()
	return eg and eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 作为起动效果的发动条件，复用eqcon2，即要求这张卡装备有名字带有「圣剑」的装备魔法卡才能发动。
function c13391185.thcon(e,tp,eg,ep,ev,re,r,rp)
	return c13391185.eqcon2(e)
end
-- 筛选对象：自己墓地中名字带有「圣骑士」的怪兽，且该怪兽可以被加入手卡。
function c13391185.thfilter(c)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的目标设定与合法性检查：选择自己墓地1只名字带有「圣骑士」的怪兽作为对象，并将其加入手卡的处理信息登记到连锁中。
function c13391185.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13391185.thfilter(chkc) end
	-- 效果发动时检查自己墓地是否存在至少1只满足条件的「圣骑士」怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c13391185.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的「圣骑士」怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c13391185.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将本次操作登记为回手牌效果，记录目标组g和数量1，供后续发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 筛选要破坏的卡：自己场上表侧表示的名字带有「圣剑」的装备魔法卡。
function c13391185.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsType(TYPE_EQUIP)
end
-- 效果处理：先将对象「圣骑士」怪兽加入手卡；若成功，再选择自己场上1张「圣剑」装备魔法卡破坏。
function c13391185.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选定的对象卡（墓地里的「圣骑士」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍然与效果关联，且已被成功加入手牌（确实在手牌中），才继续执行破坏「圣剑」的后续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 向玩家显示“请选择要破坏的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择自己场上1张表侧表示的名字带有「圣剑」的装备魔法卡，用于破坏。
		local dg=Duel.SelectMatchingCard(tp,c13391185.desfilter,tp,LOCATION_SZONE,0,1,1,nil)
		-- 中断当前效果处理，使“回手牌”与“破坏装备卡”的处理在不同时点进行，避免错过时点。
		Duel.BreakEffect()
		-- 将所选「圣剑」装备魔法卡以效果原因破坏。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
