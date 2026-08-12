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
-- 过滤函数，返回场上表侧表示的植物族怪兽数量
function c41160533.mfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 当战斗阶段开始时，若对方场上存在植物族怪兽，则为自身增加相应数量的攻击次数
function c41160533.maop(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家不是自身，则不执行后续操作
	if Duel.GetTurnPlayer()~=tp then return end
	-- 统计对方场上表侧表示的植物族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c41160533.mfilter,tp,0,LOCATION_MZONE,nil)
	if ct~=0 then
		-- 为自身增加与植物族怪兽数量相等的攻击次数
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
		e:GetHandler():RegisterEffect(e1)
	end
end
-- 判断战斗破坏的怪兽是否为植物族
function c41160533.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget():IsRace(RACE_PLANT)
end
-- 设置伤害效果的目标玩家和伤害值
function c41160533.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为300
	Duel.SetTargetParam(300)
	-- 设置连锁操作信息为对对方造成300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 执行对对方造成300点伤害的操作
function c41160533.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
