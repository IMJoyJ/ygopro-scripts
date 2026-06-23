--バトル・ブレイク
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。对方可以从手卡把1只怪兽给人观看让这张卡的效果无效。没给观看的场合，那只攻击怪兽破坏，战斗阶段结束。
function c22047978.initial_effect(c)
	-- 创建效果，设置为战斗宣言时发动，效果类别为破坏，目标为攻击怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c22047978.condition)
	e1:SetTarget(c22047978.target)
	e1:SetOperation(c22047978.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：当前回合玩家不是攻击方
function c22047978.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不等于攻击方玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 设置效果目标为攻击怪兽，若对方手牌为空则设置操作信息为破坏该怪兽
function c22047978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击怪兽
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField() end
	-- 将攻击怪兽设置为连锁对象
	Duel.SetTargetCard(tg)
	-- 判断对方手牌数量是否为0
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then
		-- 设置操作信息为破坏攻击怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	end
end
-- 过滤函数：判断手牌中是否为怪兽且未公开
function c22047978.cfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
-- 效果发动处理：判断是否可以无效连锁，若可以则询问对方是否公开手牌，若公开则无效效果，否则破坏攻击怪兽并跳过战斗阶段
function c22047978.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁是否可以被无效
	if Duel.IsChainDisablable(0) then
		local sel=1
		-- 获取对方手牌中未公开的怪兽
		local g=Duel.GetMatchingGroup(c22047978.cfilter,1-tp,LOCATION_HAND,0,nil)
		-- 提示对方选择是否公开手牌
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(22047978,0))  --"是否要从手卡把1只怪兽给对方观看？"
		if g:GetCount()>0 then
			-- 对方选择公开手牌
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			-- 对方选择不公开手牌
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			-- 提示对方选择要公开的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
			local cg=g:Select(1-tp,1,1,nil)
			-- 向攻击方确认公开的卡
			Duel.ConfirmCards(tp,cg)
			-- 对方手牌洗切
			Duel.ShuffleHand(1-tp)
			-- 使当前连锁效果无效
			Duel.NegateEffect(0)
			return
		end
	end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED)
		-- 破坏攻击怪兽并跳过战斗阶段
		and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 跳过对方的战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
