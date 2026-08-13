--バトル・ブレイク
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。对方可以从手卡把1只怪兽给人观看让这张卡的效果无效。没给观看的场合，那只攻击怪兽破坏，战斗阶段结束。
function c22047978.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。对方可以从手卡把1只怪兽给人观看让这张卡的效果无效。没给观看的场合，那只攻击怪兽破坏，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c22047978.condition)
	e1:SetTarget(c22047978.target)
	e1:SetOperation(c22047978.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件判定函数：判断发动者是否不是回合玩家，即本卡只能在对方回合的攻击宣言时发动。
function c22047978.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回发动者不是回合玩家（满足对方回合条件）时条件成立。
	return tp~=Duel.GetTurnPlayer()
end
-- 发动时的目标处理函数：将攻击怪兽设为对象；若对方手牌数为0则设置破坏该怪兽的操作信息。
function c22047978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取正在攻击宣言的怪兽作为效果对象。
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField() end
	-- 将攻击怪兽设置为当前连锁的对象。
	Duel.SetTargetCard(tg)
	-- 检查对方手牌数量是否为0（若为0则对方无法通过展示怪兽来无效本卡）。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then
		-- 设置本连锁的操作信息：破坏类别、对象为攻击怪兽、数量为1，供相关效果检测。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	end
end
-- 定义筛选条件：选择对方手卡中未公开的怪兽卡，用于对方展示。
function c22047978.cfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
-- 效果处理函数：先询问对方是否展示怪兽；若展示则无效本效果并结束，否则破坏攻击怪兽并跳过战斗阶段。
function c22047978.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前效果是否可能被无效，以决定是否给予对方选择展示怪兽的机会。
	if Duel.IsChainDisablable(0) then
		local sel=1
		-- 获取对方手卡中所有未公开的怪兽卡，作为可展示的候选。
		local g=Duel.GetMatchingGroup(c22047978.cfilter,1-tp,LOCATION_HAND,0,nil)
		-- 向对方发送提示消息：是否要从手卡把1只怪兽给对方观看？
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(22047978,0))  --"是否要从手卡把1只怪兽给对方观看？"
		if g:GetCount()>0 then
			-- 对方有可展示怪兽时，弹出两个选项（展示/不展示）；sel=0表示展示，sel=1表示不展示。
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			-- 对方没有可展示怪兽时，只提供一个不展示选项，强制 sel=1 走向不展示分支。
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			-- 向对方发送选择提示：请选择给对方确认的卡。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
			local cg=g:Select(1-tp,1,1,nil)
			-- 将对方选择的怪兽展示给我方玩家确认。
			Duel.ConfirmCards(tp,cg)
			-- 展示后洗切对方手卡，防止手卡顺序信息泄露。
			Duel.ShuffleHand(1-tp)
			-- 使当前连锁的本卡效果无效，即对方通过展示怪兽成功无效了本卡。
			Duel.NegateEffect(0)
			return
		end
	end
	-- 取得效果对象：本卡指定的攻击怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED)
		-- 以效果破坏该攻击怪兽，并判断是否破坏成功（>0表示成功）。
		and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 跳过对方（攻击方）的战斗阶段，从而结束战斗阶段。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
