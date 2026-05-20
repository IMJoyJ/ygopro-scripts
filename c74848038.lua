--死者転生
-- 效果：
-- ①：丢弃1张手卡，以自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。
function c74848038.initial_effect(c)
	-- ①：丢弃1张手卡，以自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c74848038.cost)
	e1:SetTarget(c74848038.target)
	e1:SetOperation(c74848038.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价：丢弃1张手卡
function c74848038.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手牌中是否存在可丢弃的卡（排除这张卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌中丢弃1张卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选墓地中可以加入手牌的怪兽
function c74848038.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义效果的目标选择处理
function c74848038.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74848038.tgfilter(chkc) end
	-- 在发动阶段检查自己墓地是否存在可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c74848038.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送系统提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只怪兽作为效果的对象并进行锁定
	local sg=Duel.SelectTarget(tp,c74848038.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向系统申报操作信息：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 定义效果处理：将作为对象的怪兽加入手牌
function c74848038.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
