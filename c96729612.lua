--儀式の準備
-- 效果：
-- ①：从卡组把1只7星以下的仪式怪兽加入手卡。那之后，可以从自己墓地把1张仪式魔法卡加入手卡。
function c96729612.initial_effect(c)
	-- ①：从卡组把1只7星以下的仪式怪兽加入手卡。那之后，可以从自己墓地把1张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c96729612.target)
	e1:SetOperation(c96729612.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中等级7以下且可以加入手牌的仪式怪兽
function c96729612.filter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsLevelBelow(7) and c:IsAbleToHand()
end
-- 过滤墓地中可以加入手牌的仪式魔法卡
function c96729612.filter2(c)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
end
-- 效果发动的目标选择与合法性检测函数
function c96729612.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1只满足条件的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96729612.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑，包含检索仪式怪兽以及后续可选的回收仪式魔法
function c96729612.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c96729612.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的仪式怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的仪式怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 获取自己墓地中不受王家长眠之谷影响且可以加入手牌的仪式魔法卡组
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c96729612.filter2),tp,LOCATION_GRAVE,0,nil)
		-- 如果墓地存在仪式魔法，询问玩家是否选择将其加入手牌
		if mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(96729612,0)) then  --"是否把1张仪式魔法卡加入手卡？"
			-- 中断当前效果处理，使前后的处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=mg:Select(tp,1,1,nil)
			-- 将选中的仪式魔法卡加入玩家手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的仪式魔法卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
