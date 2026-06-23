--サモンブレーカー
-- 效果：
-- 只要这张卡在场上存在，回合玩家作那个回合第3次的召唤·反转召唤·特殊召唤成功时，变成那个回合的结束阶段。这个效果在主要阶段1才发动。
function c18114794.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，回合玩家作那个回合第3次的召唤·反转召唤·特殊召唤成功时，变成那个回合的结束阶段。这个效果在主要阶段1才发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18114794,0))  --"结束回合"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_CUSTOM+18114794)
	e2:SetCondition(c18114794.condition)
	e2:SetOperation(c18114794.operation)
	c:RegisterEffect(e2)
	if not c18114794.global_check then
		c18114794.global_check=true
		c18114794[0]=0
		c18114794[1]=0
		-- 只要这张卡在场上存在，回合玩家作那个回合第3次的召唤·反转召唤·特殊召唤成功时，变成那个回合的结束阶段。这个效果在主要阶段1才发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c18114794.checkop)
		-- 注册一个用于监听通常召唤成功的持续效果
		Duel.RegisterEffect(ge1,0)
		-- 只要这张卡在场上存在，回合玩家作那个回合第3次的召唤·反转召唤·特殊召唤成功时，变成那个回合的结束阶段。这个效果在主要阶段1才发动。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		ge2:SetOperation(c18114794.checkop)
		-- 注册一个用于监听翻转召唤成功的持续效果
		Duel.RegisterEffect(ge2,0)
		-- 只要这张卡在场上存在，回合玩家作那个回合第3次的召唤·反转召唤·特殊召唤成功时，变成那个回合的结束阶段。这个效果在主要阶段1才发动。
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge3:SetOperation(c18114794.checkop)
		-- 注册一个用于监听特殊召唤成功的持续效果
		Duel.RegisterEffect(ge3,0)
	end
end
-- 当满足条件时，触发自定义事件以触发断路器效果
function c18114794.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 判断是否为新回合
	if Duel.GetTurnCount()~=c18114794[2] then
		c18114794[0]=0
		c18114794[1]=0
		-- 更新当前回合数
		c18114794[2]=Duel.GetTurnCount()
	end
	local tc=eg:GetFirst()
	local p1=false
	while tc do
		if tc:IsSummonPlayer(turnp) then
			p1=true
			break
		end
		tc=eg:GetNext()
	end
	if p1 then
		c18114794[turnp]=c18114794[turnp]+1
		if c18114794[turnp]==3 then
			-- 触发自定义事件，表示该回合玩家第3次召唤/反转/特殊召唤成功
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+18114794,e,0,0,0,0)
		end
	end
end
-- 效果发动条件：必须在主要阶段1
function c18114794.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 效果发动时执行的操作：跳过主要阶段1、战斗阶段和主要阶段2，并禁止该玩家进入战斗阶段
function c18114794.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 跳过当前回合玩家的主要阶段1
	Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合玩家的战斗阶段
	Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过当前回合玩家的主要阶段2
	Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- 创建并注册一个禁止该玩家进入战斗阶段的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止进入战斗阶段的效果注册给该玩家
	Duel.RegisterEffect(e1,turnp)
end
