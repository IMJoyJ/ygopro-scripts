--B・F・N
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己的「蜂军」怪兽被选择作为攻击对象时才能发动。从手卡·卡组把1只「蜂军」怪兽特殊召唤，给这张卡放置1个指示物。那之后，战斗阶段结束。
-- ②：结束阶段，有指示物2个以上放置的这张卡送去墓地。
function c25221249.initial_effect(c)
	-- 设置全局标记，使卡片送入墓地时不入连锁
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	c:EnableCounterPermit(0x51)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的「蜂军」怪兽被选择作为攻击对象时才能发动。从手卡·卡组把1只「蜂军」怪兽特殊召唤，给这张卡放置1个指示物。那之后，战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,25221249)
	e2:SetCondition(c25221249.condition)
	e2:SetTarget(c25221249.target)
	e2:SetOperation(c25221249.activate)
	c:RegisterEffect(e2)
	-- ②：结束阶段，有指示物2个以上放置的这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SELF_TOGRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c25221249.tgcon)
	c:RegisterEffect(e3)
end
-- 效果发动的条件：被选为攻击对象的怪兽是自己控制且为「蜂军」族
function c25221249.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and tc:IsSetCard(0x12f)
end
-- 过滤函数：筛选「蜂军」族且可特殊召唤的怪兽
function c25221249.filter(c,e,tp)
	return c:IsSetCard(0x12f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的条件检查：确认玩家可以放置指示物、场上存在空位、手卡或卡组存在「蜂军」族怪兽
function c25221249.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以放置1个指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x51,1,e:GetHandler()) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在满足条件的「蜂军」族怪兽
		and Duel.IsExistingMatchingCard(c25221249.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，确定将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理函数：若满足条件则选择并特殊召唤1只「蜂军」族怪兽，放置1个指示物，并跳过对方的战斗阶段
function c25221249.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「蜂军」族怪兽
	local g=Duel.SelectMatchingCard(tp,c25221249.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 执行特殊召唤和放置指示物操作，若成功则跳过对方战斗阶段
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and e:GetHandler():AddCounter(0x51,1)~=0 then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段结束步骤
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 效果发动的条件：当前为结束阶段且指示物数量大于等于2
function c25221249.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前阶段是否为结束阶段且指示物数量大于等于2
	return Duel.GetCurrentPhase()==PHASE_END and c:GetCounter(0x51)>=2
end
