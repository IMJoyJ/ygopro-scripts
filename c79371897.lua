--増援部隊
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己的战士族怪兽进行战斗的攻击宣言时才能发动。从手卡把1只4星以下的战士族怪兽特殊召唤。
function c79371897.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己的战士族怪兽进行战斗的攻击宣言时才能发动。从手卡把1只4星以下的战士族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79371897,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,79371897)
	e2:SetCondition(c79371897.spcon)
	e2:SetTarget(c79371897.sptg)
	e2:SetOperation(c79371897.spop)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：自己的战士族怪兽进行战斗的攻击宣言时
function c79371897.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前宣告攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 如果宣告攻击的怪兽是对方的，则将目标怪兽切换为被攻击的怪兽（即己方的被攻击怪兽）
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_WARRIOR)
end
-- 过滤手卡中等级4以下、战士族且可以特殊召唤的怪兽
function c79371897.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标合法性检测（Target函数）
function c79371897.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查己方怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时，检查手卡中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c79371897.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，用于后续连锁处理的检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行逻辑（Operation函数）
function c79371897.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若己方怪兽区域没有空位则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c79371897.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽在己方场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
