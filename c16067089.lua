--蛇神降臨
-- 效果：
-- 自己场上表侧表示存在的「毒蛇王 维诺米隆」被战斗以外破坏时才能发动。从手卡·卡组把1只「毒蛇神 维诺米纳迦」特殊召唤。
function c16067089.initial_effect(c)
	-- 自己场上表侧表示存在的「毒蛇王 维诺米隆」被战斗以外破坏时才能发动。从手卡·卡组把1只「毒蛇神 维诺米纳迦」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c16067089.condition)
	e1:SetTarget(c16067089.target)
	e1:SetOperation(c16067089.activate)
	c:RegisterEffect(e1)
end
-- 检查被破坏的卡是否为「毒蛇王 维诺米隆」（卡号72677437），且其之前控制者为发动者、之前位于场上并是表侧表示，用于确认满足“自己场上表侧表示存在的「毒蛇王 维诺米隆」被破坏”这一条件。
function c16067089.cfilter(c,tp)
	return c:IsCode(72677437) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断本次破坏事件集合中是否存在至少1张满足上述条件的「毒蛇王 维诺米隆」，以决定该效果能否发动。
function c16067089.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16067089.cfilter,1,nil,tp)
end
-- 检查候选卡是否为「毒蛇神 维诺米纳迦」（卡号8062132），且允许被本次效果特殊召唤（按通常召唤条件检查，但不检查苏生限制）。
function c16067089.filter(c,e,tp)
	return c:IsCode(8062132) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 效果发动时的合法性检查：己方主要怪兽区有空位，并且从手卡·卡组中能找到1只符合条件的「毒蛇神 维诺米纳迦」可供特殊召唤。
function c16067089.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否存在至少1个可用空格，以保证后续特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方手卡或卡组中是否存在至少1张符合条件的「毒蛇神 维诺米纳迦」供本效果特殊召唤。
		and Duel.IsExistingMatchingCard(c16067089.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，标明本次效果处理时要从手卡·卡组特殊召唤1只怪兽，供其他卡片的发动条件/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：在仍有空位的前提下，让玩家从手卡·卡组选择1只「毒蛇神 维诺米纳迦」并以表侧表示特殊召唤到己方场上；若成功召唤，再补全该卡的正规出场记录。
function c16067089.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方主要怪兽区没有可用空格，则特殊召唤无法进行，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示，引导玩家选择要特殊召唤的「毒蛇神 维诺米纳迦」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方手卡·卡组筛选并选择1张符合条件的「毒蛇神 维诺米纳迦」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c16067089.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选到卡且将其以表侧表示特殊召唤到己方场上（不检查苏生限制），则进入后续补正规出场记录的处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,true,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
