--アメイジングタイムチケット
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付800基本分才能发动。发动回合的以下效果适用。
-- ●自己回合：从卡组把1张「惊乐」卡加入手卡。
-- ●对方回合：从卡组选1张「游乐设施」陷阱卡在自己的魔法与陷阱区域盖放。这个效果盖放的卡在盖放的回合也能发动。
function c70389815.initial_effect(c)
	-- ①：支付800基本分才能发动。发动回合的以下效果适用。●自己回合：从卡组把1张「惊乐」卡加入手卡。●对方回合：从卡组选1张「游乐设施」陷阱卡在自己的魔法与陷阱区域盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,70389815+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c70389815.cost)
	e1:SetTarget(c70389815.target)
	e1:SetOperation(c70389815.activate)
	c:RegisterEffect(e1)
end
-- 支付800基本分的Cost处理
function c70389815.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤卡组中可加入手牌的「惊乐」卡
function c70389815.thfilter(c)
	return c:IsSetCard(0x15b) and c:IsAbleToHand()
end
-- 过滤卡组中可盖放的「游乐设施」陷阱卡
function c70389815.setfilter(c)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果发动的目标检查与分类设置
function c70389815.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前是否为自己回合
	if Duel.GetTurnPlayer()==tp then
		-- 检查卡组中是否存在可加入手牌的「惊乐」卡
		if chk==0 then return Duel.IsExistingMatchingCard(c70389815.thfilter,tp,LOCATION_DECK,0,1,nil) end
		e:SetCategory(CATEGORY_SEARCH)
		-- 设置连锁处理信息为从卡组将1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		-- 检查卡组中是否存在可盖放的「游乐设施」陷阱卡
		if chk==0 then return Duel.IsExistingMatchingCard(c70389815.setfilter,tp,LOCATION_DECK,0,1,nil) end
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 效果处理的执行函数
function c70389815.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己回合
	if Duel.GetTurnPlayer()==tp then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张「惊乐」卡
		local g=Duel.SelectMatchingCard(tp,c70389815.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张「游乐设施」陷阱卡
		local g=Duel.SelectMatchingCard(tp,c70389815.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		-- 如果成功在魔法与陷阱区域盖放该卡
		if tc and Duel.SSet(tp,tc)~=0 then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(70389815,0))  --"适用「惊奇时段通行证」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
