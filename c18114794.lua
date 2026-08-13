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
		-- 回合玩家作那个回合第3次的召唤·反转召唤·特殊召唤成功时
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c18114794.checkop)
		-- 将监测通常召唤成功时点（EVENT_SUMMON_SUCCESS）的全局连续效果注册到决斗中，用于统计回合玩家本回合的通常召唤次数。
		Duel.RegisterEffect(ge1,0)
		-- 反转召唤
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		ge2:SetOperation(c18114794.checkop)
		-- 将监测反转召唤成功时点（EVENT_FLIP_SUMMON_SUCCESS）的全局连续效果注册到决斗中，用于统计回合玩家本回合的反转召唤次数。
		Duel.RegisterEffect(ge2,0)
		-- 特殊召唤
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge3:SetOperation(c18114794.checkop)
		-- 将监测特殊召唤成功时点（EVENT_SPSUMMON_SUCCESS）的全局连续效果注册到决斗中，用于统计回合玩家本回合的特殊召唤次数。
		Duel.RegisterEffect(ge3,0)
	end
end
-- 召唤/反转召唤/特殊召唤成功时，判断召唤者是否为当前回合玩家；若是则将该玩家本回合的召唤次数加1，当次数达到3时触发自定义事件，使‘召唤断路器’的效果得以发动。
function c18114794.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家，用于判定本次召唤是否由回合玩家进行。
	local turnp=Duel.GetTurnPlayer()
	-- 检查当前回合数是否与记录的上次回合数不同，若不同说明已进入新回合，需要清零上一个回合的召唤计数。
	if Duel.GetTurnCount()~=c18114794[2] then
		c18114794[0]=0
		c18114794[1]=0
		-- 记录当前回合数，供下次进入新回合时判断是否重置计数。
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
			-- 当回合玩家本回合的召唤·反转召唤·特殊召唤次数达到第3次时，向‘召唤断路器’卡片发送自定义事件，使其触发“变成结束阶段”的效果。
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+18114794,e,0,0,0,0)
		end
	end
end
-- 定义‘召唤断路器’效果的发动条件：仅当当前阶段为主要阶段1时才允许发动。
function c18114794.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1，满足则效果条件成立。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 执行“变成那个回合的结束阶段”的操作：依次跳过主要阶段1、战斗阶段、主要阶段2，同时附加不能进入战斗阶段的限制，使当前回合直接进入结束阶段。
function c18114794.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家，作为跳过阶段的处理对象。
	local turnp=Duel.GetTurnPlayer()
	-- 跳过当前回合玩家的主要阶段1，使其立即结束。
	Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 跳过战斗阶段并跳过其结束步骤（value=1），防止进行战斗阶段，直接进入结束阶段。
	Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过主要阶段2，使回合流程直接进入结束阶段。
	Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- 变成那个回合的结束阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能进入战斗阶段”的持续效果注册给当前回合玩家，确保该回合无法再进行战斗阶段，从而强制变成结束阶段。
	Duel.RegisterEffect(e1,turnp)
end
