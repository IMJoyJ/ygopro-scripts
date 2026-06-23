--ライバル・アライバル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的战斗阶段才能发动。把1只怪兽召唤。
function c29508346.initial_effect(c)
	-- 效果设置：将效果注册为魔法卡发动效果，可自由连锁，限制每回合发动1次，条件为战斗阶段，目标为召唤怪兽，发动时处理召唤效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,29508346+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c29508346.condition)
	e1:SetTarget(c29508346.target)
	e1:SetOperation(c29508346.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：只有在战斗阶段开始到战斗阶段结束之间才能发动
function c29508346.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤函数：判断一张卡是否可以通常召唤（不考虑召唤次数限制）
function c29508346.filter(c)
	return c:IsSummonable(true,nil)
end
-- 效果目标：检查自己手牌或怪兽区是否有可通常召唤的怪兽，若有则设置操作信息为召唤怪兽
function c29508346.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断阶段：检查是否满足发动条件，即自己手牌或怪兽区存在可通常召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29508346.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：设置本次效果处理将要召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果发动：提示玩家选择要召唤的怪兽，并执行召唤操作
function c29508346.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：向玩家提示“请选择要召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的卡：从自己手牌或怪兽区选择1张可通常召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,c29508346.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行召唤：将选中的怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
