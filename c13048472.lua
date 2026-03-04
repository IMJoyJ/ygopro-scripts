--儀式の下準備
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选1张仪式魔法卡，再从自己的卡组·墓地选1只在那张仪式魔法卡有卡名记述的仪式怪兽。那2张卡加入手卡。
function c13048472.initial_effect(c)
	-- 效果原文：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13048472+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c13048472.target)
	e1:SetOperation(c13048472.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的仪式魔法卡
function c13048472.filter(c,tp)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
		-- 从自己的卡组·墓地选1只在那张仪式魔法卡有卡名记述的仪式怪兽
		and Duel.IsExistingMatchingCard(c13048472.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
-- 判断怪兽是否为仪式怪兽且在指定仪式魔法卡有卡名记述
function c13048472.filter2(c,mc)
	-- 效果作用：判断怪兽是否为仪式怪兽且在指定仪式魔法卡有卡名记述
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand() and aux.IsCodeListed(mc,c:GetCode())
end
-- 效果原文：①：从卡组选1张仪式魔法卡，再从自己的卡组·墓地选1只在那张仪式魔法卡有卡名记述的仪式怪兽。那2张卡加入手卡。
function c13048472.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否存在满足条件的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c13048472.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 效果作用：设置连锁操作信息，表示将要处理2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果原文：①：从卡组选1张仪式魔法卡，再从自己的卡组·墓地选1只在那张仪式魔法卡有卡名记述的仪式怪兽。那2张卡加入手卡。
function c13048472.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 效果作用：选择1张满足条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,c13048472.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 效果作用：检索满足条件的仪式怪兽
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c13048472.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,g:GetFirst())
		if mg:GetCount()>0 then
			-- 效果作用：提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			g:Merge(sg)
			-- 效果作用：将选中的2张卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 效果作用：确认对方查看加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
