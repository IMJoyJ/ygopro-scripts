--牙竜転生
-- 效果：
-- 选择从游戏中除外的1只自己的龙族怪兽加入手卡。
function c5325424.initial_effect(c)
	-- 选择从游戏中除外的1只自己的龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5325424.target)
	e1:SetOperation(c5325424.activate)
	c:RegisterEffect(e1)
end
-- 该过滤函数判断一张卡是否为表侧表示的龙族怪兽且能够加入手卡。
function c5325424.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果发动时的处理：检查自己除外区是否有符合条件的龙族怪兽；若有，则选择1张作为对象并设置将其加入手牌的操作信息。
function c5325424.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c5325424.filter(chkc) end
	-- 发动时判定：若自己除外区不存在至少1张符合条件的龙族怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c5325424.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向操作者显示选择提示“请选择要加入手牌的卡”，用于选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让操作者从自己除外区选择1张符合条件的龙族怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c5325424.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 登记本次连锁的操作信息：将所选对象卡加入手牌，以便后续相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得对象卡，若其仍与该效果关联且仍为龙族，则将其加入手牌并向对方确认。
function c5325424.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 将对象卡加入其持有者的手牌，原因记为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张卡，以确认其已加入手牌。
		Duel.ConfirmCards(1-tp,tc)
	end
end
