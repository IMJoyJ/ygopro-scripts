--サイコパス
-- 效果：
-- ①：支付800基本分，以除外的最多2只自己的念动力族怪兽为对象才能发动。那些怪兽加入手卡。
function c25401880.initial_effect(c)
	-- ①：支付800基本分，以除外的最多2只自己的念动力族怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c25401880.cost)
	e1:SetTarget(c25401880.target)
	e1:SetOperation(c25401880.activate)
	c:RegisterEffect(e1)
end
-- 支付800基本分
function c25401880.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 筛选条件：表侧表示的念动力族怪兽且可以加入手卡
function c25401880.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsAbleToHand()
end
-- 选择对象：除外区的1~2只自己的念动力族怪兽
function c25401880.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c25401880.filter(chkc) end
	-- 检查除外区是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c25401880.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1~2只除外区的念动力族怪兽作为对象
	local g=Duel.SelectTarget(tp,c25401880.filter,tp,LOCATION_REMOVED,0,1,2,nil)
	-- 设置效果处理信息为回手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 将选中的怪兽加入手卡并确认对方查看
function c25401880.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将目标怪兽以效果原因加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认查看加入手卡的怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end
