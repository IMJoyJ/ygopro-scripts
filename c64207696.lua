--EMゴールド・ファング
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，自己的「娱乐伙伴」怪兽战斗破坏对方怪兽的场合发动。给与对方1000伤害。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功的场合发动。自己场上的「娱乐伙伴」怪兽的攻击力直到回合结束时上升200。
function c64207696.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡的发动等基本属性
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己的「娱乐伙伴」怪兽战斗破坏对方怪兽的场合发动。给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64207696,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c64207696.damcon)
	e1:SetTarget(c64207696.damtg)
	e1:SetOperation(c64207696.damop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合发动。自己场上的「娱乐伙伴」怪兽的攻击力直到回合结束时上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64207696,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c64207696.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检查是否满足「自己的『娱乐伙伴』怪兽战斗破坏对方怪兽」的发动条件
function c64207696.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsSetCard(0x9f) and rc:IsControler(tp)
end
-- 设置灵摆效果①的发动目标与操作信息（给与对方1000伤害）
function c64207696.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为给与对方玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 执行灵摆效果①，给与对方玩家1000点伤害
function c64207696.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤自己场上表侧表示的「娱乐伙伴」怪兽
function c64207696.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 执行怪兽效果①，使自己场上所有的「娱乐伙伴」怪兽的攻击力直到回合结束时上升200
function c64207696.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「娱乐伙伴」怪兽
	local g=Duel.GetMatchingGroup(c64207696.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到回合结束时上升200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
