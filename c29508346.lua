--ライバル・アライバル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的战斗阶段才能发动。把1只怪兽召唤。
function c29508346.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的战斗阶段才能发动。把1只怪兽召唤。
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
-- 作为效果的发动条件，判断当前阶段是否处于战斗阶段开始到战斗阶段结束之间（即自己·对方的战斗阶段），满足才允许发动。
function c29508346.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 定义筛选条件：怪兽可直接进行通常召唤（IsSummonable(true,nil)），即忽略每回合的通常召唤次数限制，且不指定召唤用效果。
function c29508346.filter(c)
	return c:IsSummonable(true,nil)
end
-- 效果发动时的目标处理函数：chk==0时检查是否存在可召唤的怪兽以判断能否发动；chk==1时登记操作信息（召唤1只怪兽）。
function c29508346.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：在自己手牌或怪兽区寻找至少1只满足filter条件的怪兽；若存在，则效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29508346.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 登记操作信息：声明本效果要进行1只怪兽的通常召唤，因召唤对象在效果处理时确定，所以targets参数为nil。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理时的执行函数：提示玩家选择要召唤的怪兽，并将所选怪兽进行通常召唤。
function c29508346.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示框，提示内容为“请选择要召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从自己手牌和怪兽区中选择1只满足filter条件的怪兽作为召唤对象。
	local g=Duel.SelectMatchingCard(tp,c29508346.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽通常召唤到场上，并忽略每回合的通常召唤次数限制（true）。
		Duel.Summon(tp,tc,true,nil)
	end
end
