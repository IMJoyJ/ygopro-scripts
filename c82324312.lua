--ゴブリン偵察部隊
-- 效果：
-- 这张卡直接攻击对方玩家成功的场合，可以随机把对方1张手卡确认。确认的卡是魔法卡的场合，那张卡送去墓地。这张卡攻击的场合，战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡不能把表示形式改变。
function c82324312.initial_effect(c)
	-- 这张卡直接攻击对方玩家成功的场合，可以随机把对方1张手卡确认。确认的卡是魔法卡的场合，那张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82324312,0))  --"确认手牌"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c82324312.condition)
	e1:SetOperation(c82324312.operation)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡不能把表示形式改变。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c82324312.poscon)
	e2:SetOperation(c82324312.posop)
	c:RegisterEffect(e2)
end
-- 直接攻击成功时效果的发动条件
function c82324312.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定受到伤害的玩家是对方且没有攻击目标（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 直接攻击成功时效果的执行：随机确认对方1张手卡，是魔法卡则送去墓地
function c82324312.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的手牌
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(ep,1)
	-- 给发动效果的玩家确认随机选出的那张手卡
	Duel.ConfirmCards(tp,sg)
	if sg:GetFirst():IsType(TYPE_SPELL) then
		-- 将选出的卡因效果送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 洗切对方的手牌
	Duel.ShuffleHand(1-tp)
end
-- 战斗阶段结束时改变表示形式效果的发动条件（本回合进行过攻击）
function c82324312.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 战斗阶段结束时改变表示形式效果的执行：自身变成表侧守备表示，并施加不能改变表示形式的效果
function c82324312.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将自身变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 直到下次的自己回合结束时这张卡不能把表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
