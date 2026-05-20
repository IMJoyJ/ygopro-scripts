--血の代償
-- 效果：
-- 可以支付500基本分，把1只怪兽通常召唤。这个效果在自己回合的主要阶段及对方回合的战斗阶段才能发动。
function c80604091.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 可以支付500基本分，把1只怪兽通常召唤。这个效果在自己回合的主要阶段及对方回合的战斗阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80604091,0))  --"通常召唤"
	e2:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCondition(c80604091.condition)
	e2:SetCost(c80604091.cost)
	e2:SetTarget(c80604091.target)
	e2:SetOperation(c80604091.activate)
	c:RegisterEffect(e2)
end
-- 检查当前是否满足发动条件：自己回合的主要阶段，或者对方回合的战斗阶段
function c80604091.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合玩家
	local tn=Duel.GetTurnPlayer()
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (tn==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2))
		or (tn==1-tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 检查并支付500基本分的效果Cost处理
function c80604091.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分作为发动的Cost
	Duel.PayLPCost(tp,500)
end
-- 过滤函数：过滤出可以进行通常召唤（表侧表示召唤或里侧表示盖放）的怪兽
function c80604091.filter(c)
	return c:IsSummonable(true,nil) or c:IsMSetable(true,nil)
end
-- 效果发动的目标合法性检测与连锁内发动次数标识注册
function c80604091.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家手牌及场上满足通常召唤条件的怪兽数量
		local ct1=Duel.GetMatchingGroupCount(c80604091.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		-- 获取当前连锁中该效果已经声明发动的次数，用于防止同一连锁内重复选择同一张卡导致数量不足
		local ct2=Duel.GetFlagEffect(tp,80604091)
		return ct1-ct2>0
	end
	-- 在当前连锁中为玩家注册一个临时标识，用于记录该效果在同一连锁中已发动的次数
	Duel.RegisterFlagEffect(tp,80604091,RESET_CHAIN,0,1)
	-- 设置操作信息，表示该效果的处理包含1只怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理的核心逻辑：选择怪兽并进行通常召唤或里侧表示盖放
function c80604091.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌或场上选择1张满足通常召唤条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c80604091.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil)
		local s2=tc:IsMSetable(true,nil)
		-- 如果该怪兽既能表侧召唤也能里侧盖放，则让玩家选择表示形式；若只能表侧召唤，则直接判定为表侧攻击表示召唤
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 忽略每回合的通常召唤次数限制，将选中的怪兽表侧表示通常召唤
			Duel.Summon(tp,tc,true,nil)
		else
			-- 忽略每回合的通常召唤次数限制，将选中的怪兽里侧表示盖放
			Duel.MSet(tp,tc,true,nil)
		end
	end
end
