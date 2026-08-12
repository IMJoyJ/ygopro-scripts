--紅天馬ファイヤー・ウイング・ペガサス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。这个回合，这张卡可以直接攻击。
-- ②：对方把场上的怪兽的效果发动时才能发动。给与对方这个效果的发动时积累的连锁数量×300伤害，这张卡不会被那些效果破坏。
local s,id,o=GetID()
-- 创建两个效果，一个用于特殊召唤条件，一个用于连锁触发的伤害与保护效果
function s.initial_effect(c)
	-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。这个回合，这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方把场上的怪兽的效果发动时才能发动。给与对方这个效果的发动时积累的连锁数量×300伤害，这张卡不会被那些效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"给与伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
-- 判断特殊召唤条件是否满足：场上怪兽数量是否满足要求
function s.spcon(e,c)
	if c==nil then return true end
	-- 判断手牌怪兽是否能特殊召唤到场上（是否有空位）
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断对方场上的怪兽数量是否比自己场上的多
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)
end
-- 特殊召唤成功后，使该怪兽获得直接攻击能力
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 判断是否满足连锁触发伤害效果的条件
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and (loc&LOCATION_ONFIELD)~=0 and re:IsActiveType(TYPE_MONSTER)
end
-- 设置连锁伤害效果的目标和参数
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 计算连锁数量乘以300作为伤害值
	local dam=Duel.GetCurrentChain()*300
	-- 设置连锁伤害效果的伤害值
	Duel.SetTargetParam(dam)
	-- 设置连锁伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 用于判断是否为已发动的效果
function s.efilter(e,re)
	return re:IsActivated()
end
-- 执行连锁伤害效果并使该怪兽获得不被破坏效果
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁伤害效果的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成伤害
	if Duel.Damage(p,d,REASON_EFFECT)>0 then
		-- 这张卡不会被那些效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		c:RegisterEffect(e1)
	end
end
