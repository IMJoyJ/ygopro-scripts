--融合回収
-- 效果：
-- ①：以自己墓地1张「融合」和1只融合召唤使用过的融合素材怪兽为对象才能发动。那些卡加入手卡。
function c18511384.initial_effect(c)
	-- ①：以自己墓地1张「融合」和1只融合召唤使用过的融合素材怪兽为对象才能发动。那些卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18511384.target)
	e1:SetOperation(c18511384.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：墓地中存在卡名含有「融合」（卡号24094653）且能够加入手卡的卡。
function c18511384.filter1(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 筛选条件：墓地中存在曾是融合召唤使用过的融合素材怪兽（离场原因同时具有融合召唤和作为素材），且是怪兽并能够加入手卡的卡。
function c18511384.filter2(c)
	return c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时的取对象处理：检查是否存在可作为对象的「融合」和融合素材怪兽，并让玩家为效果选择这两张卡作为对象。
function c18511384.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件判定：自己墓地存在至少1张满足filter1的「融合」卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c18511384.filter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 发动条件判定：自己墓地同时存在至少1张满足filter2的融合素材怪兽可以作为对象。
		and Duel.IsExistingTarget(c18511384.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向当前玩家显示“请选择要加入手牌的卡”的选择提示，用于选择第一张对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己墓地选择1张满足filter1的「融合」卡，并将其设为效果对象。
	local g1=Duel.SelectTarget(tp,c18511384.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 再次向当前玩家显示“请选择要加入手牌的卡”的选择提示，用于选择第二张对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己墓地选择1张满足filter2的融合素材怪兽，并将其设为效果对象。
	local g2=Duel.SelectTarget(tp,c18511384.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置本次连锁的操作信息：将已选择的两张对象卡加入手牌，分类为回手牌效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果处理阶段：获取连锁的对象卡，将仍与效果关联的卡加入持有者手牌，并让对手确认这些卡。
function c18511384.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时已设定的对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将筛选出的对象卡加入其持有者的手牌，送入手牌的原因为效果处理。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手牌的卡，以进行效果公开确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
