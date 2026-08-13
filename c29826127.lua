--暗黒よりの軍勢
-- 效果：
-- ①：以自己墓地2只「暗黑界」怪兽为对象才能发动。那些怪兽加入手卡。
function c29826127.initial_effect(c)
	-- ①：以自己墓地2只「暗黑界」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c29826127.target)
	e1:SetOperation(c29826127.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己墓地中满足暗黑界字段、是怪兽且能加入手卡的卡，作为候选目标。
function c29826127.filter(c)
	return c:IsSetCard(0x6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 目标选择处理：校验对象合法性；在发动时确认存在至少2张符合条件的暗黑界怪兽，然后提示并选择2张作为对象，同时设置操作信息为将2张卡加入手卡。
function c29826127.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c29826127.filter(chkc) end
	-- 发动条件检查：确认自己墓地存在至少2张可选的暗黑界怪兽。
	if chk==0 then return Duel.IsExistingTarget(c29826127.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 显示选择卡片提示：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由玩家从自己墓地选择2张符合条件的暗黑界怪兽，并设定为效果对象。
	local g=Duel.SelectTarget(tp,c29826127.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置连锁操作信息，表明本次效果将把2张对象卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理时获取对象卡，筛选出仍与该效果关联的卡；若存在则将这些卡加入手牌，并向对方展示。
function c29826127.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象卡片组（发动时选择的2张暗黑界怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将筛选出的对象卡加入其持有者的手牌，处理原因为效果。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
