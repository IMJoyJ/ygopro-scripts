--N・ティンクル・モス
-- 效果：
-- 这张卡名在规则上也当作「新空间侠·光辉青苔」使用。这张卡用「新空间侠界限」的效果才能特殊召唤。这张卡进行战斗的场合，自己抽1张卡。这个效果抽到的卡给双方确认，这张卡得到那张卡的种类的以下效果。
-- ●怪兽卡：这个回合的战斗阶段结束。
-- ●魔法卡：这张卡可以直接攻击对方玩家。
-- ●陷阱卡：这张卡变成守备表示。
function c13857930.initial_effect(c)
	-- 记录这张卡的卡文上记载了「新空间侠·光辉青苔」的卡名。
	aux.AddCodeList(c,17732278)
	c:EnableReviveLimit()
	-- 这张卡用「新空间侠界限」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的场合，自己抽1张卡。这个效果抽到的卡给双方确认，这张卡得到那张卡的种类的以下效果。●怪兽卡：这个回合的战斗阶段结束。●魔法卡：这张卡可以直接攻击对方玩家。●陷阱卡：这张卡变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13857930,0))  --"确认手卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c13857930.condition)
	e3:SetTarget(c13857930.target)
	e3:SetOperation(c13857930.activate)
	c:RegisterEffect(e3)
	-- 这张卡名在规则上也当作「新空间侠·光辉青苔」使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_ADD_CODE)
	e4:SetValue(17732278)
	c:RegisterEffect(e4)
end
-- 战斗诱发效果的发动条件判定：检查这张卡是否为本次攻击宣言中的攻击怪兽或攻击对象怪兽。
function c13857930.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡是否正在作为攻击怪兽或被攻击对象参与本次战斗。
	return e:GetHandler()==Duel.GetAttacker() or e:GetHandler()==Duel.GetAttackTarget()
end
-- 战斗诱发效果的目标处理函数：通过临时标记防止同一战斗步骤重复触发，并申报自己抽1张卡的操作信息。
function c13857930.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(13857930)==0 end
	e:GetHandler():RegisterFlagEffect(13857930,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	-- 设置操作信息：预计由自己玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 战斗诱发效果的效果处理函数：自己抽1张卡并给对方确认，根据抽到卡片的种类执行结束战斗阶段、允许直接攻击或自身变为守备表示的处理。
function c13857930.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使自己以效果抽1张卡，若实际未能抽到卡则中止后续处理。
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 获取刚才效果抽到的那张卡片。
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡片公开给对方玩家确认。
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsType(TYPE_MONSTER) then
		-- 抽到怪兽卡时，跳过当前回合玩家的战斗阶段使其立即结束。
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	elseif tc:IsType(TYPE_SPELL) then
		-- 抽到魔法卡时，检查这张卡是否为攻击怪兽且未受到不能直接攻击的效果影响。
		if c==Duel.GetAttacker() and not c:IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK)
			-- 且检查这张卡仍与效果有联系并呈表侧表示后，询问玩家是否要进行直接攻击。
			and c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(13857930,1)) then  --"是否要进行直接攻击？"
			-- 将这张卡的攻击对象变更为直接攻击对方玩家。
			Duel.ChangeAttackTarget(nil)
		end
	else
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 抽到陷阱卡且这张卡仍呈表侧表示并与效果有联系时，将这张卡变为表侧守备表示。
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
	-- 效果处理结束后手动洗切自己的手卡。
	Duel.ShuffleHand(tp)
end
