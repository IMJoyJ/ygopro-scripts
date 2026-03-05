--ダッカー
-- 效果：
-- ①：这张卡反转的场合，以自己墓地1只4星怪兽为对象发动。那只怪兽加入手卡。
function c14506878.initial_effect(c)
	-- ①：这张卡反转的场合，以自己墓地1只4星怪兽为对象发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14506878,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c14506878.thtg)
	e1:SetOperation(c14506878.thop)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选满足条件的怪兽（等级为4且可以加入手牌）
function c14506878.filter(c)
	return c:IsLevel(4) and c:IsAbleToHand()
end
-- 设置效果的目标选择函数，用于选择符合条件的墓地怪兽
function c14506878.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14506878.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从玩家墓地中选择1只符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c14506878.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，指定将要处理的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 设置效果的处理函数，用于执行将怪兽加入手牌的操作
function c14506878.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
