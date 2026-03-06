--六武衆の荒行
-- 效果：
-- ①：以自己场上1只「六武众」怪兽为对象才能发动。和那只怪兽是卡名不同并是攻击力相同的1只「六武众」怪兽从卡组特殊召唤。作为对象的怪兽在这个回合的结束阶段破坏。
function c27821104.initial_effect(c)
	-- 效果原文内容：①：以自己场上1只「六武众」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27821104.target)
	e1:SetOperation(c27821104.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的「六武众」怪兽（卡名不同、攻击力相同、可特殊召唤）
function c27821104.tfilter(c,atk,code,e,tp)
	return c:IsSetCard(0x103d) and not c:IsCode(code) and c:IsAttack(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：过滤满足条件的「六武众」怪兽（表侧表示、是六武众、卡组存在符合条件的怪兽）
function c27821104.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		-- 效果作用：检查卡组是否存在满足条件的「六武众」怪兽
		and Duel.IsExistingMatchingCard(c27821104.tfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttack(),c:GetCode(),e,tp)
end
-- 效果作用：判断是否满足发动条件（场上存在符合条件的怪兽）
function c27821104.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c27821104.filter(chkc,e,tp) end
	-- 效果作用：判断场上是否有特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查场上是否存在符合条件的怪兽作为对象
		and Duel.IsExistingTarget(c27821104.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c27821104.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果原文内容：和那只怪兽是卡名不同并是攻击力相同的1只「六武众」怪兽从卡组特殊召唤。
function c27821104.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否有特殊召唤怪兽的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从卡组选择符合条件的怪兽
	local sg=Duel.SelectMatchingCard(tp,c27821104.tfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetAttack(),tc:GetCode(),e,tp)
	if sg:GetCount()>0 then
		-- 效果作用：将符合条件的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 效果原文内容：作为对象的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetOperation(c27821104.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	tc:RegisterEffect(e1)
end
-- 效果作用：破坏对象怪兽
function c27821104.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：以效果原因破坏对象怪兽
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
