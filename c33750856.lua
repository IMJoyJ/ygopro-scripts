--コード・ハック
-- 效果：
-- ①：自己场上的电子界族连接怪兽不会被对方的效果破坏。
-- ②：1回合1次，自己和对方的怪兽之间进行战斗的战斗步骤才能发动。那只对方怪兽的攻击力直到回合结束时变成0，双方怪兽不会被那次战斗破坏，那次战斗发生的双方的战斗伤害变成0。
-- ③：自己的「码语者」怪兽攻击的伤害步骤对方把效果发动时，把墓地的这张卡除外才能发动。那个发动无效，那只攻击怪兽的攻击力上升700。
local s,id,o=GetID()
-- 初始化函数：注册e1作为魔陷发动用激活效果，e2实现①的永续抗性，e3实现②的战斗时效果，e4实现③的墓地无效并加攻效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的电子界族连接怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indestg)
	-- 设置e2的Value为aux.indoval，使其只有在对方效果时才对己方电子界连接怪兽提供不被破坏的耐性。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己和对方的怪兽之间进行战斗的战斗步骤才能发动。那只对方怪兽的攻击力直到回合结束时变成0，双方怪兽不会被那次战斗破坏，那次战斗发生的双方的战斗伤害变成0。
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
	-- ③：自己的「码语者」怪兽攻击的伤害步骤对方把效果发动时，把墓地的这张卡除外才能发动。那个发动无效，那只攻击怪兽的攻击力上升700。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCondition(s.negcon)
	-- 设置③效果的发动代价为把墓地的这张卡除外。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 筛选符合①效果保护的对象：电子界族且连接怪兽的己方怪兽。
function s.indestg(e,c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK)
end
-- ②效果的发动条件：当前为战斗步骤，且存在攻击目标（自己和对方的怪兽正在进行战斗）。
function s.zacon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否存在攻击目标且当前阶段为战斗步骤，以此限定只能在战斗步骤中发动。
	return Duel.GetAttackTarget() and Duel.GetCurrentPhase()==PHASE_BATTLE_STEP
end
-- ②效果的目标判定：获取对方正在战斗的怪兽，并确认其表侧表示且攻击力不为0。
function s.zatg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方玩家操控的正在战斗中的怪兽。
	local tc=Duel.GetBattleMonster(1-tp)
	-- 在发动合法性检查时，要求存在对方战斗怪兽且其攻击力大于0，满足条件才允许发动。
	if chk==0 then return tc and aux.nzatk(tc) end
end
-- ②效果处理：将对方战斗怪兽攻击力变为0；给双方战斗怪兽附加不会被那次战斗破坏的效果；并让该次战斗对双方玩家的战斗伤害变为0。
function s.zaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方正在战斗中的怪兽。
	local tc=Duel.GetBattleMonster(1-tp)
	-- 确认对方战斗怪兽仍与战斗相关且攻击力大于0，防止处理已离场或攻击力已为0的怪兽。
	if tc and tc:IsRelateToBattle() and aux.nzatk(tc) then
		-- 那只对方怪兽的攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
		-- 双方怪兽不会被那次战斗破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		tc:GetBattleTarget():RegisterEffect(e3)
		-- ②：那次战斗发生的双方的战斗伤害变成0；③：那个发动无效，那只攻击怪兽的攻击力上升700。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetTargetRange(1,1)
		e4:SetValue(1)
		e4:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 将此伤害避免效果注册给当前玩家，使其影响双方玩家，实现那次战斗的战斗伤害变成0。
		Duel.RegisterEffect(e4,tp)
	end
end
-- ③效果的发动条件：对方在伤害步骤中发动效果，自己为回合玩家，且攻击怪兽是自己的「码语者」怪兽。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方发动的效果（rp为对方），当前是伤害步骤，并且当前回合玩家是自己。
	return rp==1-tp and Duel.GetCurrentPhase()==PHASE_DAMAGE and Duel.GetTurnPlayer()==tp
		-- 并且攻击怪兽是「码语者」系列，满足“自己的「码语者」怪兽攻击”的前提。
		and Duel.GetAttacker():IsSetCard(0x101)
end
-- ③效果的目标处理：不取对象；设置本次无效的对象为对方发动的那个效果（eg）。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，将CATEGORY_NEGATE与对方发动的效果关联，便于后续连锁处理与无效判定。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ③效果处理：无效对方发动的那个效果；若无效成功且攻击怪兽仍与战斗相关，则使其攻击力上升700。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽，即自己的「码语者」怪兽。
	local tc=Duel.GetAttacker()
	-- 尝试无效对方效果的发动，并确认攻击怪兽仍存在于战斗中，才执行加攻效果。
	if Duel.NegateActivation(ev) and tc:IsRelateToBattle() then
		-- 那只攻击怪兽的攻击力上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
	end
end
