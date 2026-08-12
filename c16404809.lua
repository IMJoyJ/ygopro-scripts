--クリバンデット
-- 效果：
-- ①：这张卡召唤的回合的结束阶段，把这张卡解放才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张魔法·陷阱卡加入手卡。剩下的卡送去墓地。
function c16404809.initial_effect(c)
	-- ①：这张卡召唤的回合的结束阶段，把这张卡解放才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c16404809.sumsuc)
	c:RegisterEffect(e1)
	-- 从自己卡组上面把5张卡翻开。可以从那之中选1张魔法·陷阱卡加入手卡。剩下的卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16404809,0))  --"翻开卡组"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c16404809.condition)
	e2:SetCost(c16404809.cost)
	e2:SetTarget(c16404809.target)
	e2:SetOperation(c16404809.operation)
	c:RegisterEffect(e2)
end
-- 记录召唤成功的标志位，用于判断是否可以发动效果
function c16404809.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(16404809,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 检查是否已记录召唤成功的标志位，决定是否可以发动效果
function c16404809.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(16404809)~=0
end
-- 检查是否可以支付解放费用
function c16404809.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检查玩家是否可以翻开卡组顶部5张卡
function c16404809.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以翻开卡组顶部5张卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
end
-- 筛选魔法或陷阱卡的过滤函数
function c16404809.filter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 处理效果的主要逻辑：翻开卡组顶部5张卡，选择魔法或陷阱卡加入手牌，其余卡送去墓地
function c16404809.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以翻开卡组顶部5张卡
	if not Duel.IsPlayerCanDiscardDeck(tp,5) then return end
	-- 翻开玩家卡组顶部5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取玩家卡组顶部5张卡的卡片组
	local g=Duel.GetDecktopGroup(tp,5)
	if g:GetCount()>0 then
		-- 禁用后续操作的洗牌检测
		Duel.DisableShuffleCheck()
		-- 判断是否有魔法或陷阱卡可选并询问玩家是否选择
		if g:IsExists(c16404809.filter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(16404809,1)) then  --"是否要把一张魔法或陷阱卡加入手卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,c16404809.filter,1,1,nil)
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认选中的卡
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切自己的手牌
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
		-- 将剩余的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	end
end
