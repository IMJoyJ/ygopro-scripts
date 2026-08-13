--凡人の施し
-- 效果：
-- 从卡组抽2张卡，之后从手卡把1张通常怪兽卡从游戏中除外。手卡没有通常怪兽卡的场合，手卡全部送去墓地。
function c40465719.initial_effect(c)
	-- 从卡组抽2张卡，那之后把手卡1只通常怪兽从游戏中除外。手卡没有通常怪兽的场合，手卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c40465719.target)
	e1:SetOperation(c40465719.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判定与发动信息设定：检查能否除外和抽牌，将对象玩家设为自身、抽牌数设为2，并登记抽卡2张的操作信息。
function c40465719.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：仅当玩家能够除外手卡且能够抽2张卡时才可发动。
	if chk==0 then return Duel.IsPlayerCanRemove(tp) and Duel.IsPlayerCanDraw(tp,2) end
	-- 设定效果的对象玩家为当前发动玩家，用于后续抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设定效果对象参数为2，即抽卡张数为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：进行抽卡2张的操作，目标玩家为tp，用于连锁时点及效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：抽2张卡，洗切手牌，然后中断效果使后续处理分开；接着选择手牌中1只通常怪兽除外，若不存在则将所有手牌送去墓地。
function c40465719.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出目标玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 玩家p抽d张卡（原因：效果）。
	Duel.Draw(p,d,REASON_EFFECT)
	-- 抽卡后洗切玩家p的手牌，使新抽到的卡随机排列。
	Duel.ShuffleHand(p)
	-- 中断当前效果处理，使后续选择除外或送墓处理与抽卡处理视为不同时处理，从而不错过时点。
	Duel.BreakEffect()
	-- 向玩家tp显示选择提示'请选择要除外的卡'，用于后续选择通常怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从玩家p手卡中尝试选择1只通常怪兽（若存在），作为要除外的候选。
	local g=Duel.SelectMatchingCard(p,Card.IsType,p,LOCATION_HAND,0,1,1,nil,TYPE_NORMAL)
	local tg=g:GetFirst()
	if tg then
		-- 尝试以表侧表示除外该通常怪兽；若返回0表示除外未成功（如受不能除外的影响），则进入确认分支。
		if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)==0 then
			-- 若除外失败，向对方玩家确认这张卡，以表明手牌存在通常怪兽但无法除外。
			Duel.ConfirmCards(1-p,tg)
			-- 确认后再次洗切玩家p的手牌。
			Duel.ShuffleHand(p)
		end
	else
		-- 当手牌中没有通常怪兽时，获取玩家p手牌中的全部卡片。
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		-- 将玩家p的全部手牌送去墓地（原因：效果）。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
