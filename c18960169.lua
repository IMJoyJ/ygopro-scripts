--ゴブリン陽動部隊
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，可以从自己卡组抽1张卡。这张卡攻击的场合，战斗阶段结束时变成守备表示，直到下次的自己回合的结束阶段时不能把表示形式改变。
function c18960169.initial_effect(c)
	-- 效果原文：这张卡给与对方基本分战斗伤害时，可以从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18960169,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c18960169.condition)
	e1:SetTarget(c18960169.target)
	e1:SetOperation(c18960169.operation)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡攻击的场合，战斗阶段结束时变成守备表示，直到下次的自己回合的结束阶段时不能把表示形式改变。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c18960169.poscon)
	e2:SetOperation(c18960169.posop)
	c:RegisterEffect(e2)
end
-- 规则层面：判断造成战斗伤害的玩家是否为对方玩家
function c18960169.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 规则层面：设置抽卡效果的目标玩家和抽卡数量
function c18960169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 规则层面：设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面：设置效果的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 规则层面：设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面：执行抽卡操作
function c18960169.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁中设置的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面：让目标玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 规则层面：判断该卡是否在战斗阶段中被攻击过
function c18960169.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 规则层面：处理战斗阶段结束时的表示形式改变效果
function c18960169.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 规则层面：将目标怪兽变为守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 规则层面：使目标怪兽在下次结束阶段前不能改变表示形式
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
