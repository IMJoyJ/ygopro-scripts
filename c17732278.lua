--N・グロー・モス
-- 效果：
-- 这张卡进行战斗的场合，对方抽1张卡。这个效果抽到的卡给双方确认，这张卡得到那张卡的种类的以下效果。
-- ●怪兽卡：这个回合的战斗阶段结束。
-- ●魔法卡：这张卡可以直接攻击对方玩家。
-- ●陷阱卡：这张卡变成守备表示。
function c17732278.initial_effect(c)
	-- ①：这张卡进行战斗的攻击宣言时发动。对方抽1张，给双方确认。那张卡的种类的以下效果适用。●怪兽：这个回合的战斗阶段结束。●魔法：可以把这张卡的攻击变成直接攻击。●陷阱：这张卡变成守备表示。
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
-- 效果发动条件：这张卡作为攻击怪兽或作为攻击对象进行攻击宣言时满足。
function c17732278.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡是否为正在进行攻击宣言的攻击怪兽或攻击对象。
	return e:GetHandler()==Duel.GetAttacker() or e:GetHandler()==Duel.GetAttackTarget()
end
-- 效果发动时的合法性检查：若发动检查时该卡没有本效果标志则允许发动；同时注册一个到伤害阶段结束前有效的标志防止重复发动，并设置“让对方抽1张”的操作信息。
function c17732278.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(17732278)==0 end
	e:GetHandler():RegisterFlagEffect(17732278,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	-- 设置操作信息：声明本效果为抽卡效果，将让对方玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果处理主体：对方抽1张卡并展示，根据卡的种类执行对应效果：怪兽则结束战斗阶段，魔法则在我方选择后改为直接攻击，陷阱则变为守备表示。
function c17732278.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 对方玩家因效果抽1张卡；若没有抽到则效果处理终止。
	if Duel.Draw(1-tp,1,REASON_EFFECT)==0 then return end
	-- 获取这次抽卡实际抽到的那张卡。
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 将对方抽到的那张卡展示给我方玩家确认。
	Duel.ConfirmCards(tp,tc)
	if tc:IsType(TYPE_MONSTER) then
		-- 跳过当前回合玩家的战斗阶段，并指定在战斗阶段或战斗步骤结束时重置。
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	elseif tc:IsType(TYPE_SPELL) then
		-- 若这张卡是攻击怪兽，且没有受到“不能直接攻击”效果影响。
		if c==Duel.GetAttacker() and not c:IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK)
			-- 同时这张卡仍与该效果关联、处于表侧表示，且我方选择同意直接攻击。
			and c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(17732278,1)) then  --"是否要进行直接攻击？"
			-- 把攻击对象改为空，使这张卡变成直接攻击。
			Duel.ChangeAttackTarget(nil)
		end
	else
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 把这张卡变为表侧守备表示。
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
	-- 洗切对方玩家的手卡。
	Duel.ShuffleHand(1-tp)
end
