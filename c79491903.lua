--レプティレス・ナージャ
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡和怪兽进行战斗的战斗阶段结束时发动。那些怪兽的攻击力变成0。
-- ③：这张卡守备表示存在的场合，自己结束阶段发动。表侧守备表示的这张卡变成表侧攻击表示。
function c79491903.initial_effect(c)
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡和怪兽进行战斗的战斗阶段结束时发动。那些怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79491903,0))  --"攻击变成0"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c79491903.atktg)
	e2:SetOperation(c79491903.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡守备表示存在的场合，自己结束阶段发动。表侧守备表示的这张卡变成表侧攻击表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79491903,1))  --"变成表侧攻击表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c79491903.postg)
	e3:SetOperation(c79491903.posop)
	c:RegisterEffect(e3)
end
-- 过滤与该卡进行过战斗的对方场上的表侧表示怪兽
function c79491903.filter(c,bc)
	return c:IsFaceup() and c:GetBattledGroup():IsContains(bc)
end
-- 效果②的发动准备与目标过滤函数
function c79491903.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在与该卡进行过战斗的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79491903.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler()) end
end
-- 效果②的效果处理函数，将相关怪兽的攻击力变成0
function c79491903.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有与该卡进行过战斗的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c79491903.filter,tp,0,LOCATION_MZONE,nil,e:GetHandler())
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 效果③的发动准备与目标过滤函数
function c79491903.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前是否为自己的回合，且该卡是否在场上守备表示存在
	if chk==0 then return Duel.GetTurnPlayer()==tp and e:GetHandler():IsDefensePos() end
	-- 设置效果处理的操作信息为改变该卡的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理函数，将该卡变更为表侧攻击表示
function c79491903.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsDefensePos() then
		-- 将该卡变更为表侧攻击表示
		Duel.ChangePosition(c,0,0,POS_FACEUP_ATTACK,0)
	end
end
