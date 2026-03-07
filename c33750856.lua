--コード・ハック
-- 效果：
-- ①：自己场上的电子界族连接怪兽不会被对方的效果破坏。
-- ②：1回合1次，自己和对方的怪兽之间进行战斗的战斗步骤才能发动。那只对方怪兽的攻击力直到回合结束时变成0，双方怪兽不会被那次战斗破坏，那次战斗发生的双方的战斗伤害变成0。
-- ③：自己的「码语者」怪兽攻击的伤害步骤对方把效果发动时，把墓地的这张卡除外才能发动。那个发动无效，那只攻击怪兽的攻击力上升700。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，使卡能被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的电子界族连接怪兽不会被对方的效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indestg)
	-- 设置效果值为过滤函数aux.indoval，用于判断是否能被对方效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- 1回合1次，自己和对方的怪兽之间进行战斗的战斗步骤才能发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.zacon)
	e3:SetTarget(s.zatg)
	e3:SetOperation(s.zaop)
	c:RegisterEffect(e3)
	-- 自己的「码语者」怪兽攻击的伤害步骤对方把效果发动时，把墓地的这张卡除外才能发动
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCondition(s.negcon)
	-- 将此卡从墓地除外作为cost
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上的电子界族连接怪兽
function s.indestg(e,c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK)
end
-- 条件判断：当前处于战斗步骤且有攻击对象
function s.zacon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前处于战斗步骤且有攻击对象
	return Duel.GetAttackTarget() and Duel.GetCurrentPhase()==PHASE_BATTLE_STEP
end
-- 设置效果目标：对方战斗中的怪兽
function s.zatg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方战斗中的怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	-- 检查目标怪兽是否存在且攻击力大于0
	if chk==0 then return tc and aux.nzatk(tc) end
end
-- 处理效果：使对方怪兽攻击力变为0、双方怪兽不会被那次战斗破坏、战斗伤害变为0
function s.zaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方战斗中的怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	-- 检查对方战斗怪兽是否存在且与战斗相关且攻击力大于0
	if tc and tc:IsRelateToBattle() and aux.nzatk(tc) then
		-- 使对方怪兽攻击力变为0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
		-- 使对方怪兽不会被那次战斗破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		tc:GetBattleTarget():RegisterEffect(e3)
		-- 使双方战斗伤害变为0
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetTargetRange(1,1)
		e4:SetValue(1)
		e4:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 注册战斗伤害无效效果
		Duel.RegisterEffect(e4,tp)
	end
end
-- 条件判断：对方发动效果且处于伤害步骤且为己方回合且攻击怪兽为码语者族
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动效果且处于伤害步骤且为己方回合
	return rp==1-tp and Duel.GetCurrentPhase()==PHASE_DAMAGE and Duel.GetTurnPlayer()==tp
		-- 攻击怪兽为码语者族
		and Duel.GetAttacker():IsSetCard(0x101)
end
-- 设置效果目标：使对方效果发动无效
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使对方效果发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 处理效果：使对方效果发动无效，攻击怪兽攻击力上升700
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	-- 检查攻击怪兽与战斗相关且对方效果发动有效
	if Duel.NegateActivation(ev) and tc:IsRelateToBattle() then
		-- 使攻击怪兽攻击力上升700
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
	end
end
