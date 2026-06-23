--凡人の施し
-- 效果：
-- 从卡组抽2张卡，之后从手卡把1张通常怪兽卡从游戏中除外。手卡没有通常怪兽卡的场合，手卡全部送去墓地。
function c40465719.initial_effect(c)
	-- 创建效果，设置效果类别为抽卡、除外和送去墓地，效果类型为发动，具有以玩家为对象的特性，连锁类型为自由连锁，设置目标函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c40465719.target)
	e1:SetOperation(c40465719.activate)
	c:RegisterEffect(e1)
end
-- 效果目标函数，检查玩家是否可以除外卡片和抽卡
function c40465719.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否为初次检查，若可以除外和抽2张卡则返回true
	if chk==0 then return Duel.IsPlayerCanRemove(tp) and Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的目标玩家为tp
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动函数，执行抽卡、洗牌、中断效果、提示选择除外卡、选择通常怪兽卡并除外或送去墓地
function c40465719.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 将目标玩家的手牌洗切
	Duel.ShuffleHand(p)
	-- 中断当前效果，使后续效果处理视为不同时处理
	Duel.BreakEffect()
	-- 向目标玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标玩家手牌中满足条件的通常怪兽卡
	local g=Duel.SelectMatchingCard(p,Card.IsType,p,LOCATION_HAND,0,1,1,nil,TYPE_NORMAL)
	local tg=g:GetFirst()
	if tg then
		-- 尝试将选中的卡除外，若失败则确认对方可见并洗牌
		if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)==0 then
			-- 向对方玩家确认选中的卡
			Duel.ConfirmCards(1-p,tg)
			-- 将目标玩家的手牌洗切
			Duel.ShuffleHand(p)
		end
	else
		-- 获取目标玩家手牌全部卡片组
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		-- 将目标玩家手牌全部送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
