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
-- 将此卡解放作为费用
function c32485518.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检索满足条件的卡片组
function c32485518.filter(c)
	return c:IsCode(4064256) and c:IsAbleToHand()
end
-- 选择目标卡片
function c32485518.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32485518.filter(chkc) end
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingTarget(c32485518.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,c32485518.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 将选中的卡片加入手牌
function c32485518.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方查看该卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
