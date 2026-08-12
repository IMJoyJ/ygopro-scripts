--無効
-- 效果：
-- 抽卡的效果发动时发动。那张卡的效果所抽的卡双方确认，并全部丢弃去墓地。
function c80863132.initial_effect(c)
	-- 抽卡的效果发动时发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c80863132.condition)
	e1:SetOperation(c80863132.activate)
	c:RegisterEffect(e1)
end
-- 检查被连锁的效果是否为以玩家为对象的单一抽卡效果
function c80863132.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET) then return false end
	-- 检查被连锁的效果的操作分类数量是否为1（确保没有其他复合效果）
	if Duel.GetOperationCount(ev)~=1 then return false end
	-- 获取被连锁效果的抽卡操作信息，包括是否包含抽卡、抽卡玩家和抽卡张数
	local ex,cg,cc,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DRAW)
	return ex and cv>0
end
-- 效果处理：将被连锁的效果的处理函数替换为本卡的效果处理
function c80863132.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 改变连锁中指定效果的处理，将其替换为自定义的 repop 函数
	Duel.ChangeChainOperation(ev,c80863132.repop)
end
-- 替换后的效果处理：使原本要抽卡的玩家改为将相同数量的卡组最上方的卡送去墓地
function c80863132.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取原效果中预定抽卡的玩家和抽卡张数
	local ex,cg,cc,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DRAW)
	if cp<2 then
		-- 将原效果中预定抽卡的玩家的卡组最上方对应张数的卡送去墓地
		Duel.DiscardDeck(cp,cv,REASON_EFFECT)
	end
end
