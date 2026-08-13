--B・F・N
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己的「蜂军」怪兽被选择作为攻击对象时才能发动。从手卡·卡组把1只「蜂军」怪兽特殊召唤，给这张卡放置1个指示物。那之后，战斗阶段结束。
-- ②：结束阶段，有指示物2个以上放置的这张卡送去墓地。
function c25221249.initial_effect(c)
	-- 启用全局标记GLOBALFLAG_SELF_TOGRAVE，使不入连锁的自我送墓效果（EFFECT_SELF_TOGRAVE）能被正确检测和处理。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	c:EnableCounterPermit(0x51)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己的「蜂军」怪兽被选择作为攻击对象时才能发动。从手卡·卡组把1只「蜂军」怪兽特殊召唤，给这张卡放置1个指示物。那之后，战斗阶段结束。
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
-- ①效果的发动条件判定：被选择为攻击对象的怪兽必须是自己场上表侧表示且为「蜂军」怪兽。
function c25221249.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and tc:IsSetCard(0x12f)
end
-- 特殊召唤的候选过滤：从手卡·卡组中筛选出属于「蜂军」字段且能够被当前效果特殊召唤的怪兽。
function c25221249.filter(c,e,tp)
	return c:IsSetCard(0x12f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标判定：确认这张卡能否放置指示物、自己主要怪兽区是否有空位，以及手卡·卡组中是否存在至少1只可特殊召唤的「蜂军」怪兽。
function c25221249.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己能否向这张卡放置1个蜂军指示物，以及自己主要怪兽区是否有空闲区域。
	if chk==0 then return Duel.IsCanAddCounter(tp,0x51,1,e:GetHandler()) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只满足特殊召唤条件的「蜂军」怪兽。
		and Duel.IsExistingMatchingCard(c25221249.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，告知系统本效果涉及从手卡·卡组进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ①效果的处理：选择并特殊召唤「蜂军」怪兽，成功后再给这张卡放置1个指示物，然后跳过对方战斗阶段。
function c25221249.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有可用区域，则直接终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1只满足条件的「蜂军」怪兽（注意此处代码只从卡组选择，未包含手卡）。
	local g=Duel.SelectMatchingCard(tp,c25221249.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若特殊召唤成功且这张卡成功放置了1个指示物，则继续执行后面跳过战斗阶段的处理。
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and e:GetHandler():AddCounter(0x51,1)~=0 then
		-- 中断当前效果链，使后续的跳过战斗阶段处理视为不同时处理，避免因同时处理而错过时点。
		Duel.BreakEffect()
		-- 跳过对方玩家的战斗阶段，使战斗阶段直接结束。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- ②效果的自动送墓条件：当前为结束阶段，且这张卡上放置有2个以上的指示物。
function c25221249.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前是否处于结束阶段，并且这张卡上的指示物数量是否大于等于2。
	return Duel.GetCurrentPhase()==PHASE_END and c:GetCounter(0x51)>=2
end
