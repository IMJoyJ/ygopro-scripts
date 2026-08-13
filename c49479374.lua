--急速充電器
-- 效果：
-- 把自己墓地存在的2只4星以下的名字带有「电池人」的怪兽加入手卡。
function c49479374.initial_effect(c)
	-- 把自己墓地存在的2只4星以下的名字带有「电池人」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c49479374.target)
	e1:SetOperation(c49479374.activate)
	c:RegisterEffect(e1)
end
-- 定义怪兽筛选条件：持有「电池人」字段（0x28）、等级4以下且可以被加入手卡。
function c49479374.filter(c)
	return c:IsSetCard(0x28) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 发动时的目标处理函数：先处理连锁对象合法性校验，再检查自己墓地是否存在至少2只满足条件的怪兽；若存在则提示玩家从墓地选择2只作为对象，并登记将2张卡加入手卡的操作信息。
function c49479374.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c49479374.filter(chkc) end
	-- 仅检查阶段（chk==0）的发动合法性判断：确认自己墓地存在至少2只可作为对象且满足条件的「电池人」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c49479374.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 显示选择提示消息，提示玩家正在选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择正好2只满足条件的「电池人」怪兽，并设为该连锁的效果对象。
	local g=Duel.SelectTarget(tp,c49479374.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 登记当前连锁的操作信息：本次效果将把2张对象卡加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理函数：从连锁信息中取出发动时选择的对象，筛选出仍与该效果相关的卡；若还有相关卡，则将其加入手卡并给对方确认。
function c49479374.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象卡组（即发动时选择的2只墓地怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍相关的对象卡全部加入其持有者的手卡，处理原因标记为效果（REASON_EFFECT）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 把加入手卡的这些怪兽展示给对方玩家确认，保证信息透明。
		Duel.ConfirmCards(1-tp,sg)
	end
end
