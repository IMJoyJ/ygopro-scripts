--魂食神龍ドレイン・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。自己的龙族超量怪兽的效果才能特殊召唤。这张卡特殊召唤成功时，自己基本分比对方少的场合，这张卡的攻击力上升那个相差数值，这个回合对方玩家受到的全部伤害变成0。此外，这张卡不能向对方玩家直接攻击。
function c55735315.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己的龙族超量怪兽的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c55735315.splimit)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，自己基本分比对方少的场合，这张卡的攻击力上升那个相差数值，这个回合对方玩家受到的全部伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55735315,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c55735315.atkcon)
	e2:SetOperation(c55735315.atkop)
	c:RegisterEffect(e2)
	-- 此外，这张卡不能向对方玩家直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤条件，判定是否为龙族超量怪兽的效果进行特殊召唤
function c55735315.splimit(e,se,sp,st)
	local sc=se:GetHandler()
	return sc:IsType(TYPE_XYZ) and sc:IsRace(RACE_DRAGON)
end
-- 特殊召唤成功时效果的发动条件：自己基本分比对方少
function c55735315.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己当前生命值是否小于对方当前生命值
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 特殊召唤成功时的效果处理：使自身攻击力上升生命值差值，并使本回合对方受到的全部伤害变成0
function c55735315.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否在场上表侧表示、是否仍与效果相关，且自己生命值依然比对方少
	if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		-- 这张卡的攻击力上升那个相差数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		-- 设置攻击力上升的数值为双方生命值的差值
		e1:SetValue(Duel.GetLP(1-tp)-Duel.GetLP(tp))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 这个回合对方玩家受到的全部伤害变成0
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetValue(0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，使对方玩家本回合受到的所有伤害（战斗和效果伤害）变成0
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，使对方玩家本回合受到的效果伤害变成0（用于免伤检测）
	Duel.RegisterEffect(e3,tp)
end
