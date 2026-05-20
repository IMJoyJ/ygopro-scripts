--コンフュージョン・チャフ
-- 效果：
-- 同1次的战斗阶段中宣言第2次的直接攻击时才能发动。那只对方怪兽和直接攻击过的第1只对方怪兽战斗进行伤害计算。
function c67630339.initial_effect(c)
	-- 同1次的战斗阶段中宣言第2次的直接攻击时才能发动。那只对方怪兽和直接攻击过的第1只对方怪兽战斗进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c67630339.condition)
	e1:SetOperation(c67630339.operation)
	c:RegisterEffect(e1)
	if not c67630339.global_check then
		c67630339.global_check=true
		c67630339[0]=0
		c67630339[1]=0
		-- 同1次的战斗阶段中宣言第2次的直接攻击时才能发动
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c67630339.check)
		-- 注册全局效果，在每次攻击宣言时记录直接攻击的次数和怪兽
		Duel.RegisterEffect(ge1,0)
		-- 同1次的战斗阶段中宣言第2次的直接攻击时才能发动
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ATTACK_DISABLED)
		ge2:SetOperation(c67630339.check2)
		-- 注册全局效果，在攻击被无效时减少直接攻击的计数
		Duel.RegisterEffect(ge2,0)
		-- 同1次的战斗阶段中宣言第2次的直接攻击时才能发动。那只对方怪兽和直接攻击过的第1只对方怪兽战斗进行伤害计算。
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge3:SetOperation(c67630339.clear)
		-- 注册全局效果，在每个回合开始时重置直接攻击的计数
		Duel.RegisterEffect(ge3,0)
	end
end
-- 攻击宣言时的全局监听函数，用于记录直接攻击的次数，并标记第一只直接攻击的怪兽
function c67630339.check(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判断本次攻击是否为直接攻击（没有攻击目标）
	if Duel.GetAttackTarget()==nil then
		c67630339[1-tc:GetControler()]=c67630339[1-tc:GetControler()]+1
		-- 给进行直接攻击的怪兽注册一个持续到回合结束的标识
		Duel.GetAttacker():RegisterFlagEffect(67630339,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		if c67630339[1-tc:GetControler()]==1 then
			-- 记录第一只进行直接攻击的怪兽
			c67630339[2]=Duel.GetAttacker()
		end
	end
end
-- 攻击被无效时的全局监听函数，用于修正直接攻击的计数
function c67630339.check2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判断被无效攻击的怪兽是否带有直接攻击标识，且攻击目标不为空
	if tc:GetFlagEffect(67630339)~=0 and Duel.GetAttackTarget()~=nil then
		c67630339[1-tc:GetControler()]=c67630339[1-tc:GetControler()]-1
	end
end
-- 回合开始时的重置函数，将双方玩家的直接攻击计数清零
function c67630339.clear(e,tp,eg,ep,ev,re,r,rp)
	c67630339[0]=0
	c67630339[1]=0
end
-- 卡片发动的条件：对方回合、当前是直接攻击、且是同一次战斗阶段中的第二次直接攻击，且第一只直接攻击的怪兽仍在场，且当前攻击怪兽不是第一只怪兽
function c67630339.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是对方回合的直接攻击，且当前是该玩家在本次战斗阶段中受到的第2次直接攻击
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==nil and c67630339[tp]==2
		-- 且第1只直接攻击的怪兽仍具有直接攻击标识，且当前攻击的怪兽不是第1只直接攻击的怪兽
		and c67630339[2]:GetFlagEffect(67630339)~=0 and Duel.GetAttacker()~=c67630339[2]
end
-- 卡片发动后的效果处理：使当前攻击的怪兽与第1只直接攻击的怪兽进行伤害计算
function c67630339.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽（即第2只直接攻击的怪兽）
	local a=Duel.GetAttacker()
	local d=c67630339[2]
	if a:GetFlagEffect(67630339)~=0 and d:GetFlagEffect(67630339)~=0
		and a:IsAttackable() and not a:IsImmuneToEffect(e) and not d:IsImmuneToEffect(e) then
		-- 令当前攻击的怪兽与第1只直接攻击的怪兽进行战斗伤害计算
		Duel.CalculateDamage(a,d)
	end
end
