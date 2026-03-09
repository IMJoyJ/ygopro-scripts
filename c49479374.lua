--急速充電器
-- 效果：
-- 把自己墓地存在的2只4星以下的名字带有「电池人」的怪兽加入手卡。
function c49479374.initial_effect(c)
	-- 效果原文内容：把自己墓地存在的2只4星以下的名字带有「电池人」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c49479374.target)
	e1:SetOperation(c49479374.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：名字带有「电池人」且等级在4以下且可以送去手卡的怪兽
function c49479374.filter(c)
	return c:IsSetCard(0x28) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 效果作用：选择目标，从自己墓地选择2只满足条件的怪兽作为对象
function c49479374.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c49479374.filter(chkc) end
	-- 判断是否满足发动条件：确认自己墓地是否存在至少2只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c49479374.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的2张墓地怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c49479374.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置连锁操作信息，指定将选中的2张卡送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理：将符合条件的怪兽送入手卡并确认对方查看
function c49479374.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中已选定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将目标怪兽以效果原因送入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认查看送入手卡的怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end
