--融合回収
-- 效果：
-- ①：以自己墓地1张「融合」和1只融合召唤使用过的融合素材怪兽为对象才能发动。那些卡加入手卡。
function c18511384.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1张「融合」和1只融合召唤使用过的融合素材怪兽为对象才能发动。那些卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18511384.target)
	e1:SetOperation(c18511384.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「融合」魔法卡（卡号24094653）
function c18511384.filter1(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 检索满足条件的融合召唤使用过的融合素材怪兽
function c18511384.filter2(c)
	return c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断效果发动条件是否满足
function c18511384.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己墓地是否存在满足条件的「融合」魔法卡
	if chk==0 then return Duel.IsExistingTarget(c18511384.filter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 判断自己墓地是否存在满足条件的融合素材怪兽
		and Duel.IsExistingTarget(c18511384.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「融合」魔法卡
	local g1=Duel.SelectTarget(tp,c18511384.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的融合素材怪兽
	local g2=Duel.SelectTarget(tp,c18511384.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理时要操作的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果处理函数，将符合条件的卡加入手牌并确认对方查看
function c18511384.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
