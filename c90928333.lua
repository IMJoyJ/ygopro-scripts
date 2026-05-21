--闇の量産工場
-- 效果：
-- ①：以自己墓地2只通常怪兽为对象才能发动。那些怪兽加入手卡。
function c90928333.initial_effect(c)
	-- ①：以自己墓地2只通常怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c90928333.target)
	e1:SetOperation(c90928333.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选属于通常怪兽且可以加入手牌的卡片
function c90928333.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 效果发动的目标确认与对象选择处理
function c90928333.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c90928333.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在至少2只可以成为对象的通常怪兽
	if chk==0 then return Duel.IsExistingTarget(c90928333.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家发送提示信息，要求选择加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地2只通常怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c90928333.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理信息，表示该效果会将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理：将作为对象的怪兽加入手牌
function c90928333.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为连锁对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将这些卡片加入持有者的手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
