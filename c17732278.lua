--N・グロー・モス
-- 效果：
-- 这张卡进行战斗的场合，对方抽1张卡。这个效果抽到的卡给双方确认，这张卡得到那张卡的种类的以下效果。
-- ●怪兽卡：这个回合的战斗阶段结束。
-- ●魔法卡：这张卡可以直接攻击对方玩家。
-- ●陷阱卡：这张卡变成守备表示。
function c17732278.initial_effect(c)
	-- 创建一个诱发必发效果，用于在战斗阶段开始时触发抽卡效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17732278,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c17732278.condition)
	e1:SetTarget(c17732278.target)
	e1:SetOperation(c17732278.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为攻击或被攻击的怪兽
function c17732278.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前怪兽是否为攻击怪兽或攻击目标怪兽
	return e:GetHandler()==Duel.GetAttacker() or e:GetHandler()==Duel.GetAttackTarget()
end
-- 设置效果的处理目标，准备进行抽卡操作
function c17732278.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(17732278)==0 end
	e:GetHandler():RegisterFlagEffect(17732278,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	-- 设置连锁操作信息，表示将要进行抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 处理效果的主要逻辑，包括抽卡、确认卡片类型并执行对应效果
function c17732278.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让对方玩家抽一张卡，若未抽到则不继续处理
	if Duel.Draw(1-tp,1,REASON_EFFECT)==0 then return end
	-- 获取对方抽到的那张卡
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡展示给对方玩家确认
	Duel.ConfirmCards(tp,tc)
	if tc:IsType(TYPE_MONSTER) then
		-- 若抽到的是怪兽卡，则跳过战斗阶段结束步骤
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	elseif tc:IsType(TYPE_SPELL) then
		-- 判断当前怪兽是否为攻击怪兽且未被禁止直接攻击
		if c==Duel.GetAttacker() and not c:IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK)
			-- 确认当前怪兽处于有效状态且玩家选择进行直接攻击
			and c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(17732278,1)) then  --"是否要进行直接攻击？"
			-- 将攻击目标设为对方玩家，实现直接攻击效果
			Duel.ChangeAttackTarget(nil)
		end
	else
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 将当前怪兽变为守备表示
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
	-- 将对方玩家的手卡进行洗切
	Duel.ShuffleHand(1-tp)
end
