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
	-- 这张卡进行战斗的场合，自己抽1张卡。这个效果抽到的卡给双方确认，这张卡得到那张卡的种类的以下效果。
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
-- 效果作用
function c13857930.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为攻击怪兽或攻击目标怪兽
	return e:GetHandler()==Duel.GetAttacker() or e:GetHandler()==Duel.GetAttackTarget()
end
-- 效果作用
function c13857930.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(13857930)==0 end
	e:GetHandler():RegisterFlagEffect(13857930,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果作用
function c13857930.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让玩家抽一张卡
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 获取抽到的卡片
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 给对方确认抽到的卡片
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsType(TYPE_MONSTER) then
		-- 跳过战斗阶段结束步骤
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	elseif tc:IsType(TYPE_SPELL) then
		-- 判断是否为攻击怪兽且未被禁止直接攻击
		if c==Duel.GetAttacker() and not c:IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK)
			-- 确认是否选择直接攻击对方玩家
			and c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(13857930,1)) then  --"是否要进行直接攻击？"
			-- 设置攻击对象为对方玩家
			Duel.ChangeAttackTarget(nil)
		end
	else
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 将此卡变为守备表示
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
