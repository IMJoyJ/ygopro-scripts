--ガジェット・アームズ
-- 效果：
-- 反转：选择自己墓地存在的1张名字带有「变形斗士」的魔法或者陷阱卡加入手卡。
function c47985614.initial_effect(c)
	-- 反转：选择自己墓地存在的1张名字带有「变形斗士」的魔法或者陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47985614,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c47985614.target)
	e1:SetOperation(c47985614.operation)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的卡：必须是名字带有「变形斗士」的魔法/陷阱卡，并且能够被加入手卡。
function c47985614.filter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动时的目标处理：检查对象是否合法；无对象时返回可发动；提示玩家选择自己墓地1张符合条件的「变形斗士」魔法/陷阱卡，并将该卡设为效果对象，同时设置回手牌的操作信息。
function c47985614.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47985614.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家tp显示“请选择要加入手牌的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己墓地的卡中选出1张满足filter条件的卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c47985614.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次效果处理的信息：将选中的卡加入手牌（CATEGORY_TOHAND），数量为选中张数，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取回对象卡，若该卡仍与效果关联，则将其加入持有者手牌，并向对方展示确认。
function c47985614.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
