--紅天馬ファイヤー・ウイング・ペガサス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。这个回合，这张卡可以直接攻击。
-- ②：对方把场上的怪兽的效果发动时才能发动。给与对方这个效果的发动时积累的连锁数量×300伤害，这张卡不会被那些效果破坏。
local s,id,o=GetID()
-- 为红天马火翼飞马注册两个效果：①作为特殊召唤规则效果（从手卡通过满足条件特殊召唤，并附加直接攻击）和②作为诱发即时效果（对方发动场上怪兽效果时给伤害并附加破坏抗性）。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
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
-- ①特殊召唤手续的发动条件：自己场上存在空的怪兽区域，且对方场上的怪兽数量多于自己场上的怪兽数量。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否存在可用的怪兽区域（用于特殊召唤）。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 比较双方场上怪兽数量：对方场上怪兽数大于自己场上怪兽数（这是①特殊召唤的条件之一）。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)
end
-- ①特殊召唤成功时，给这张卡赋予这个回合可以直接攻击的效果。
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
-- ②效果的发动条件：对方发动了场上的怪兽效果（ep==1-tp表示发动方为对方；loc在场上且re为怪兽效果）。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中触发效果的发动位置，用于判定该效果是否从场上发动。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and (loc&LOCATION_ONFIELD)~=0 and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果发动时确定对象和伤害：将对方玩家设为对象，伤害值为当前连锁数×300，并设置操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次效果造成伤害的对象玩家设为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 计算伤害数值：当前连锁数量×300。
	local dam=Duel.GetCurrentChain()*300
	-- 将计算出的伤害值存储为效果处理参数，供效果处理时使用。
	Duel.SetTargetParam(dam)
	-- 设置操作信息，声明本次连锁将造成CATEGORY_DAMAGE伤害，对象为对方玩家，数值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 作为EFFECT_INDESTRUCTABLE_EFFECT的判定函数：若试图破坏此卡的效果已经发动（re:IsActivated()为真），则此卡不会被该效果破坏。
function s.efilter(e,re)
	return re:IsActivated()
end
-- ②效果处理：先给对方玩家造成伤害；若实际造成了伤害，则给这张卡附加不会被那些效果破坏的状态。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁信息中取出之前设定的伤害对象玩家p和伤害数值d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行伤害：给对象玩家造成d点效果伤害，Duel.Damage的返回值>0表示伤害成立，继续附加抗性。
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
