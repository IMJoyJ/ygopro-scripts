--墓守の石版
-- 效果：
-- 选择自己墓地存在的2只名字带有「守墓」的怪兽加入手卡。这个效果不会被「王家长眠之谷」的效果无效化。
function c99523325.initial_effect(c)
	-- 选择自己墓地存在的2只名字带有「守墓」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99523325.target)
	e1:SetOperation(c99523325.activate)
	c:RegisterEffect(e1)
	-- 这个效果不会被「王家长眠之谷」的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NECRO_VALLEY_IM)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：选出自己墓地中满足“名字带有「守墓」、是怪兽且能加入手卡”的卡片。
function c99523325.filter(c)
	return c:IsSetCard(0x2e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标选择处理：判断能否选择对象，选择2张自己墓地的「守墓」怪兽作为效果对象，并设置加入手牌的操作信息。
function c99523325.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c99523325.filter(chkc) end
	-- 在效果发动时（chk==0）检查自己墓地是否存在至少2只满足条件的「守墓」怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(c99523325.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择正好2只满足条件的「守墓」怪兽，并将它们设定为当前效果的对象。
	local g=Duel.SelectTarget(tp,c99523325.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置当前连锁的操作信息：宣告将选中的2张卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理时的操作：从连锁信息中取得对象卡，过滤出仍与此效果相关的卡，将其加入手牌，并让对方确认。
function c99523325.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理时记录的效果对象卡组，即发动时选择的2张卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
