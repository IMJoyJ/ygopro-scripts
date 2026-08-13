--コモンメンタルワールド
-- 效果：
-- 每次自己对同调怪兽的同调召唤成功，给与对方基本分500分伤害。
function c61032879.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己对同调怪兽的同调召唤成功，给与对方基本分500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61032879,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c61032879.condition)
	e2:SetTarget(c61032879.target)
	e2:SetOperation(c61032879.operation)
	c:RegisterEffect(e2)
end
-- 检查本次特殊召唤成功的是否为同调召唤且控制者为自己，即是否满足“自己对同调怪兽的同调召唤成功”的条件。
function c61032879.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsSummonType(SUMMON_TYPE_SYNCHRO) and eg:GetFirst():IsControler(tp)
end
-- 效果发动时进行合法判定，并确定伤害对象为对方、伤害数值为500，同时设置对应的伤害操作信息。
function c61032879.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁处理的伤害对象玩家设置为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁处理的伤害数值参数设置为500。
	Duel.SetTargetParam(500)
	-- 设置操作信息，声明本连锁将造成500点效果伤害，目标为对方玩家，供相关卡片的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,500)
end
-- 效果处理阶段，若此卡仍在魔陷区且效果未被无效，则根据之前设定好的目标玩家和伤害数值给予对方500分伤害。
function c61032879.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 从当前连锁信息中取出之前设定的对象玩家和伤害参数，即伤害对象与伤害数值。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 以效果原因对对象玩家造成对应数值的伤害。
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
