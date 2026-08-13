--N・ティンクル・モス
-- 效果：
-- 这张卡名在规则上也当作「新空间侠·光辉青苔」使用。这张卡用「新空间侠界限」的效果才能特殊召唤。这张卡进行战斗的场合，自己抽1张卡。这个效果抽到的卡给双方确认，这张卡得到那张卡的种类的以下效果。
-- ●怪兽卡：这个回合的战斗阶段结束。
-- ●魔法卡：这张卡可以直接攻击对方玩家。
-- ●陷阱卡：这张卡变成守备表示。
function c13857930.initial_effect(c)
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
-- 战斗宣言时，若此卡为攻击怪兽或攻击对象则条件成立。
function c13857930.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡是否为攻击怪兽或攻击对象（即是否参与本次战斗）。
	return e:GetHandler()==Duel.GetAttacker() or e:GetHandler()==Duel.GetAttackTarget()
end
-- 效果发动条件检查：若此卡本回合尚未发动过该效果，则允许发动；发动时注册一次效果标记，并声明抽1张卡的操作信息。
function c13857930.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(13857930)==0 end
	e:GetHandler():RegisterFlagEffect(13857930,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	-- 设置本连锁的处理信息，声明将进行抽1张卡的操作，供其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：自己抽1张卡，将抽到的卡给对方确认，然后根据该卡种类处理：怪兽卡则结束战斗阶段，魔法卡则可直接攻击（需玩家选择），陷阱卡则变成守备表示。
function c13857930.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行抽1张卡（原因为效果），若实际未能抽到则本次效果处理中断。
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 取得此次抽卡操作实际抽到的那张卡。
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsType(TYPE_MONSTER) then
		-- 跳过当前回合玩家的战斗阶段，即结束战斗阶段（对应怪兽卡的效果）。
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	elseif tc:IsType(TYPE_SPELL) then
		-- 判断此卡是否为攻击怪兽且自身没有“不能直接攻击”的效果限制，以决定是否可适用直接攻击。
		if c==Duel.GetAttacker() and not c:IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK)
			-- 并且此卡仍与该效果关联、表侧表示，且玩家确认要执行直接攻击。
			and c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(13857930,1)) then  --"是否要进行直接攻击？"
			-- 将攻击目标改为空，即变为对对方玩家的直接攻击。
			Duel.ChangeAttackTarget(nil)
		end
	else
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 将此卡变为表侧守备表示（对应陷阱卡的效果）。
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
	-- 洗切手牌，以重置手牌顺序（抽卡后手牌洗切）。
	Duel.ShuffleHand(tp)
end
