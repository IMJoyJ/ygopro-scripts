--素早いマンタ
-- 效果：
-- 场上存在的这张卡被卡的效果送去墓地时，可以从自己卡组把「迅捷蝠鲼」任意数量特殊召唤。
function c46384403.initial_effect(c)
	-- 诱发选发效果，满足条件时可以发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46384403,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c46384403.condition)
	e1:SetTarget(c46384403.target)
	e1:SetOperation(c46384403.operation)
	c:RegisterEffect(e1)
end
-- 场上存在的这张卡被卡的效果送去墓地时
function c46384403.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_EFFECT)
end
-- 检查是否满足特殊召唤的条件
function c46384403.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在满足条件的「迅捷蝠鲼」
	if chk==0 then return Duel.IsExistingMatchingCard(c46384403.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选可以特殊召唤的「迅捷蝠鲼」
function c46384403.filter(c,e,tp)
	return c:IsCode(46384403) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，执行特殊召唤操作
function c46384403.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的「迅捷蝠鲼」
	local g=Duel.SelectMatchingCard(tp,c46384403.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
