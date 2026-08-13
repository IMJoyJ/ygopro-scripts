--クリバンデット
-- 效果：
-- ①：这张卡召唤的回合的结束阶段，把这张卡解放才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张魔法·陷阱卡加入手卡。剩下的卡送去墓地。
function c16404809.initial_effect(c)
	-- 这张卡召唤的回合
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c16404809.sumsuc)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤的回合的结束阶段，把这张卡解放才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张魔法·陷阱卡加入手卡。剩下的卡送去墓地。
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
-- 召唤成功时给此卡设置一个flag，标记该卡在本回合已召唤成功，持续到结束阶段或离场等重置。
function c16404809.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(16404809,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 效果发动条件：该卡存在本回合召唤成功的flag，即满足“这张卡召唤的回合的结束阶段”的条件。
function c16404809.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(16404809)~=0
end
-- 代价函数：先检查此卡是否可解放（chk==0），满足后执行解放此卡作为发动代价。
function c16404809.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价解放此卡（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 发动时的必要检查：确认自己卡组顶端是否有5张卡可以送去墓地，以保证效果能够处理。
function c16404809.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查chk==0时自己卡组顶5张卡是否可以被送去墓地，若不能则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
end
-- 过滤条件：翻开卡中为魔法·陷阱卡且可以加入手卡的卡，用于选择可加入手卡的魔法·陷阱卡。
function c16404809.filter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理：翻开卡组顶5张，若有可加入手卡的魔法·陷阱卡则询问是否加入；选择1张加入手卡并向对方展示、洗牌；剩余卡全部送去墓地。
function c16404809.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认卡组顶5张可送墓，若不能则终止效果处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,5) then return end
	-- 翻开并确认自己卡组最上方的5张卡。
	Duel.ConfirmDecktop(tp,5)
	-- 获取卡组最上方的5张卡作为处理对象组g。
	local g=Duel.GetDecktopGroup(tp,5)
	if g:GetCount()>0 then
		-- 禁用本次操作后的自动洗牌检测，避免从卡组顶取卡后自动洗切卡组。
		Duel.DisableShuffleCheck()
		-- 若翻开的5张卡中存在可加入手卡的魔法·陷阱卡，且玩家选择“是”，则进入选卡加入手卡的处理。
		if g:IsExists(c16404809.filter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(16404809,1)) then  --"是否要把一张魔法或陷阱卡加入手卡？"
			-- 向玩家发送选择提示，要求选择要加入手卡的卡片（HINTMSG_ATOHAND）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,c16404809.filter,1,1,nil)
			-- 将选中的1张卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切自己的手牌，避免对方通过加入的卡获知手牌信息。
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
		-- 将翻开后未加入手卡（剩余）的卡以效果原因并作为“翻开”过的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	end
end
