--ローズ・テンタクルス
-- 效果：
-- 这张卡不能特殊召唤。自己的战斗阶段开始时对方场上有表侧表示植物族怪兽存在的场合，这个回合这张卡可以在通常攻击外加上那些植物族怪兽数量的攻击。这张卡战斗破坏植物族怪兽的场合，给与对方基本分300分伤害。
function c41160533.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己的战斗阶段开始时对方场上有表侧表示植物族怪兽存在的场合，这个回合这张卡可以在通常攻击外加上那些植物族怪兽数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c41160533.maop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏植物族怪兽的场合，给与对方基本分300分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41160533,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCondition(c41160533.damcon)
	e3:SetTarget(c41160533.damtg)
	e3:SetOperation(c41160533.damop)
	c:RegisterEffect(e3)
end
-- 筛选出表侧表示的植物族怪兽。
function c41160533.mfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 战斗阶段开始时处理：若是这张卡的控制者的回合，统计对方场上表侧植物族怪兽数量，若存在则给这张卡赋予额外攻击次数效果。
function c41160533.maop(e,tp,eg,ep,ev,re,r,rp)
	-- 若不是这张卡的控制者的回合，则直接结束处理，不发动额外攻击效果。
	if Duel.GetTurnPlayer()~=tp then return end
	-- 统计对方场上表侧表示植物族怪兽的数量。
	local ct=Duel.GetMatchingGroupCount(c41160533.mfilter,tp,0,LOCATION_MZONE,nil)
	if ct~=0 then
		-- 这个回合这张卡可以在通常攻击外加上那些植物族怪兽数量的攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
		e:GetHandler():RegisterEffect(e1)
	end
end
-- 战斗破坏植物族怪兽是伤害效果的发动条件。
function c41160533.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget():IsRace(RACE_PLANT)
end
-- 伤害效果的发动时点处理：设置伤害对象为对方玩家、伤害数值为300，并登记效果处理信息。
function c41160533.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次伤害的对象玩家设置为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次效果的伤害数值参数设为300。
	Duel.SetTargetParam(300)
	-- 登记伤害类效果处理信息，对象为对手，数值为300。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 伤害效果处理：取出目标玩家和伤害数值，给予其效果伤害。
function c41160533.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出之前设置的目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成对应数值的效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
