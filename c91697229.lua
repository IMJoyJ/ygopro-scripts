--極星邪狼フェンリル
-- 效果：
-- 这张卡不能通常召唤。自己主要阶段2，场上有「极神」怪兽存在的场合可以从手卡往对方场上守备表示特殊召唤。
-- ①：场上没有「极神」怪兽存在的场合这张卡破坏。
-- ②：自己战斗阶段开始时发动。自己场上的守备表示怪兽全部变成表侧攻击表示。
-- ③：这张卡的战斗发生的战斗伤害由双方玩家承受。
function c91697229.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己主要阶段2，场上有「极神」怪兽存在的场合可以从手卡往对方场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91697229,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,1)
	e1:SetCondition(c91697229.spcon)
	c:RegisterEffect(e1)
	-- ①：场上没有「极神」怪兽存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c91697229.descon)
	c:RegisterEffect(e4)
	-- ②：自己战斗阶段开始时发动。自己场上的守备表示怪兽全部变成表侧攻击表示。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(91697229,1))  --"表示变更"
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c91697229.poscon)
	e5:SetTarget(c91697229.postg)
	e5:SetOperation(c91697229.posop)
	c:RegisterEffect(e5)
	-- ③：这张卡的战斗发生的战斗伤害由双方玩家承受。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_BOTH_BATTLE_DAMAGE)
	c:RegisterEffect(e6)
end
-- 特殊召唤规则的条件函数：检查是否在自己主要阶段2、对方场上有空位且场上存在「极神」怪兽
function c91697229.spcon(e,c)
	-- 若未指定卡片，则仅检查当前阶段是否为主要阶段2
	if c==nil then return Duel.GetCurrentPhase()==PHASE_MAIN2 end
	local tp=c:GetControler()
	-- 检查对方场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 且场上（双方场上）存在至少1张满足过滤条件的卡（「极神」怪兽）
		and Duel.IsExistingMatchingCard(c91697229.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤函数：检查卡片是否表侧表示且属于「极神」系列
function c91697229.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
-- 自我破坏效果的条件函数：场上没有「极神」怪兽存在
function c91697229.descon(e)
	-- 检查场上（双方场上）是否不存在表侧表示的「极神」怪兽
	return not Duel.IsExistingMatchingCard(c91697229.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 表示形式变更效果的条件函数：当前回合玩家为自己
function c91697229.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为效果的发动者（自己）
	return Duel.GetTurnPlayer()==tp
end
-- 表示形式变更效果的目标函数：获取自己场上所有的守备表示怪兽并设置操作信息
function c91697229.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上所有守备表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,0,nil)
	-- 设置效果处理信息为改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 表示形式变更效果的操作函数：将自己场上的守备表示怪兽全部变成表侧攻击表示
function c91697229.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取自己场上所有守备表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将获取到的怪兽全部改变为表侧攻击表示
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end
