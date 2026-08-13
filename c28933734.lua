--闇の仮面
-- 效果：
-- ①：这张卡反转的场合，以自己墓地1张陷阱卡为对象发动。那张卡加入手卡。
function c28933734.initial_effect(c)
	-- ①：这张卡反转的场合，以自己墓地1张陷阱卡为对象发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c28933734.target)
	e1:SetOperation(c28933734.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择自己墓地中满足条件的卡——必须是陷阱卡且能够加入手卡。
function c28933734.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的取对象/发动条件处理：验证指定对象是否为自己墓地的陷阱卡且可加入手卡；在效果发动时提示选择并选择自己墓地1张陷阱卡作为对象，同时设置把该卡加入手卡的操作信息。
function c28933734.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28933734.filter(chkc) end
	if chk==0 then return true end
	-- 给当前玩家显示选择提示文字：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己墓地中筛选并选择1张满足filter条件的陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c28933734.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息：本次操作包含“加入手卡”的效果分类，对象为已选择的卡组g，数量为g中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理阶段：从取对象信息中获取对象卡，若该卡仍与效果关联，则将其加入手卡，并向对方玩家确认。
function c28933734.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁效果所选择的取对象卡片（即自己墓地中被选为对象的陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该对象卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张被加入手卡的卡，使其确认此卡信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
