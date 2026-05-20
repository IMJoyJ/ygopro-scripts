--壱時砲固定式
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的战斗阶段，宣言1·2·3·4·5·6的其中任意数字才能发动。选对方场上1只效果怪兽，以下数值的合计数字和自己墓地的卡数量相同的场合，把最多有宣言的数字数量的卡从自己卡组上面送去墓地，选最多有送去墓地的数量的对方场上的卡回到持有者卡组。不是的场合，自己失去宣言的数字×500基本分。
-- ●选的怪兽的等级×宣言的数字
-- ●对方场上的卡数量
function c70916046.initial_effect(c)
	-- ①：自己·对方的战斗阶段，宣言1·2·3·4·5·6的其中任意数字才能发动。选对方场上1只效果怪兽，以下数值的合计数字和自己墓地的卡数量相同的场合，把最多有宣言的数字数量的卡从自己卡组上面送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,70916046+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c70916046.condition)
	e1:SetTarget(c70916046.target)
	e1:SetOperation(c70916046.activate)
	c:RegisterEffect(e1)
end
-- 检查当前是否处于自己或对方的战斗阶段
function c70916046.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤条件：表侧表示、效果怪兽且等级在1以上
function c70916046.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsLevelAbove(1)
end
-- 效果发动时的处理：检查发动条件，并初始化可宣言的数字列表（1至6）
function c70916046.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在符合条件的效果怪兽，且对方场上存在卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c70916046.filter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	local t={}
	local i=1
	for i=1,6 do t[i]=i end
	-- 让发动效果的玩家宣言1到6的其中一个数字，并将该数字作为标签保存
	e:SetLabel(Duel.AnnounceNumber(tp,table.unpack(t)))
	-- 获取对方场上所有可以回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：包含从卡组送去墓地的效果
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,0)
	-- 设置操作信息：包含让对方场上的卡回到卡组的效果
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,0,0,0)
end
-- 效果处理：选择对方场上1只效果怪兽，若计算的合计数字与自己墓地卡数相同，则将卡组上方的卡送去墓地，否则自己失去基本分
function c70916046.activate(e,tp,eg,ep,ev,re,r,rp)
	local dnum=e:GetLabel()
	-- 获取对方场上的卡片数量
	local fnum=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 获取自己墓地的卡片数量
	local gnum=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只符合条件的效果怪兽
	local dg=Duel.SelectMatchingCard(tp,c70916046.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #dg==0 then return end
	local mon=dg:GetFirst()
	local lnum=mon:GetLevel()
	if ((lnum*dnum)+fnum)==gnum then
		-- 提示玩家选择要送去墓地的卡（此处实际用于提示宣言要送去墓地的卡片数量）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 获取自己卡组的卡片数量
		local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local t={}
		local i=1
		if dcount<=dnum then
			for i=1,dcount do t[i]=i end
		else
			for i=1,dnum do t[i]=i end
		end
		-- 让玩家宣言要送去墓地的卡片数量（最多为宣言的数字且不超过卡组剩余数量）
		local snum=Duel.AnnounceNumber(tp,table.unpack(t))
		-- 将宣言数量的卡从自己卡组上面送去墓地，若成功送去墓地则继续处理
		if Duel.DiscardDeck(tp,snum,REASON_EFFECT)~=0 then
			-- 获取实际被送去墓地的卡片组
			local og=Duel.GetOperatedGroup()
			local tdnum=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
			-- 获取对方场上可以回到卡组的卡片组
			local tdg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
			if tdnum<=0 or #tdg<=0 then return end
			-- 提示玩家选择要回到卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local rg=tdg:Select(tp,1,tdnum,nil)
			-- 选中对方场上要回到卡组的卡片并闪烁显示
			Duel.HintSelection(rg)
			-- 将选中的对方场上的卡片送回持有者卡组并洗牌
			Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	else
		-- 合计数字不相同时，自己失去宣言的数字×500的基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-dnum*500)
	end
end
