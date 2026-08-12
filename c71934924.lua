--疾風！凶殺陣
-- 效果：
-- 自己场上名字带有「六武众」的怪兽进行过战斗的场合，直到这个回合的结束阶段时自己场上名字带有「六武众」的怪兽的攻击力上升300。
function c71934924.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上名字带有「六武众」的怪兽进行过战斗的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c71934924.atop)
	c:RegisterEffect(e2)
	-- 直到这个回合的结束阶段时自己场上名字带有「六武众」的怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetOperation(c71934924.upop)
	c:RegisterEffect(e3)
end
-- 检查卡片是否为自己场上的「六武众」怪兽
function c71934924.check(c,tp)
	return c and c:IsSetCard(0x103d) and c:IsControler(tp)
end
-- 伤害计算后，若自己场上的「六武众」怪兽进行了战斗，则给本卡注册一个持续到伤害步骤结束的标识
function c71934924.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽或被攻击怪兽是否为自己场上的「六武众」怪兽
	if c71934924.check(Duel.GetAttacker(),tp) or c71934924.check(Duel.GetAttackTarget(),tp) then
		e:GetHandler():RegisterFlagEffect(71934924,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 过滤自己场上表侧表示且未获得过此攻击力上升效果的「六武众」怪兽
function c71934924.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:GetFlagEffect(71934924)==0
end
-- 伤害步骤结束时，若本步骤内有自己场上的「六武众」怪兽进行过战斗，则使自己场上所有符合条件的「六武众」怪兽攻击力上升300，直到回合结束阶段
function c71934924.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(71934924)==0 then return end
	-- 获取自己场上所有符合条件的「六武众」怪兽
	local g=Duel.GetMatchingGroup(c71934924.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 直到这个回合的结束阶段时自己场上名字带有「六武众」的怪兽的攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(71934924,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
end
