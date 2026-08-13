--イモータル・ルーラー
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：把这张卡解放，以自己墓地1张「不死世界」为对象才能发动。那张卡加入手卡。
function c32485518.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：把这张卡解放，以自己墓地1张「不死世界」为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32485518,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c32485518.cost)
	e2:SetTarget(c32485518.target)
	e2:SetOperation(c32485518.operation)
	c:RegisterEffect(e2)
end
-- 代价函数：chk==0时检查自身是否可解放（作为发动代价的满足条件）；正式支付时将自身解放来支付代价。
function c32485518.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价解放此卡自身（REASON_COST），用于支付起动效果的发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡名必须是「不死世界」（卡号4064256），且能够被加入手卡（未受“不能加入手卡”等效果限制）。
function c32485518.filter(c)
	return c:IsCode(4064256) and c:IsAbleToHand()
end
-- 发动时的目标处理：校验对象是己方墓地且满足过滤条件的卡；存在合法对象后提示玩家选择1张墓地「不死世界」作为对象，并登记为取对象及回手牌操作信息。
function c32485518.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32485518.filter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1张满足条件（不死世界且可加入手卡）的卡，才能发动。
	if chk==0 then return Duel.IsExistingTarget(c32485518.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向发动玩家显示“选择要加入手牌的卡”的提示消息，并将该提示文字写入选择缓存，供后续选择卡片时显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己墓地选择1张满足过滤条件的「不死世界」作为效果对象；该选择会登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c32485518.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将当前连锁效果标记为回手牌（CATEGORY_TOHAND），目标为所选对象，数量为其张数，用于系统联动检测与效果结算记录。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果结算处理：取回发动时选择的对象，若对象仍与此效果关联，则将其加入持有者手卡，并向对方展示，完成①效果。
function c32485518.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中登记的唯一的对象卡（先前选择的墓地「不死世界」）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将该卡送回持有者的手卡，即“那张卡加入手卡”。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家公开确认这张加入手卡的卡片，以便确认其为「不死世界」。
		Duel.ConfirmCards(1-tp,tc)
	end
end
