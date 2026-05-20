--スーパイ
-- 效果：
-- ①：这张卡被效果从场上送去墓地时才能发动。从卡组把1只「太阳之神官」特殊召唤。这个效果特殊召唤的怪兽攻击力变成2倍，这个回合的结束阶段回到持有者手卡。
function c78552773.initial_effect(c)
	-- ①：这张卡被效果从场上送去墓地时才能发动。从卡组把1只「太阳之神官」特殊召唤。这个效果特殊召唤的怪兽攻击力变成2倍，这个回合的结束阶段回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78552773,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c78552773.spcon)
	e1:SetTarget(c78552773.sptg)
	e1:SetOperation(c78552773.spop)
	c:RegisterEffect(e1)
end
-- 发动条件：检查这张卡是否是从场上因效果被送去墓地
function c78552773.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤条件：卡组中卡名为「太阳之神官」且可以特殊召唤的怪兽
function c78552773.filter(c,e,tp)
	return c:IsCode(42280216) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动靶向：检查怪兽区域空位以及卡组中是否存在可特殊召唤的「太阳之神官」，并设置特殊召唤的操作信息
function c78552773.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的「太阳之神官」
		and Duel.IsExistingMatchingCard(c78552773.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组特殊召唤1只「太阳之神官」，使其攻击力变成2倍，并注册在结束阶段回到持有者手卡的效果
function c78552773.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的「太阳之神官」
	local g=Duel.SelectMatchingCard(tp,c78552773.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选出怪兽，则尝试将其以表侧表示特殊召唤（分步处理）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local atk=tc:GetAttack()
		-- 这个效果特殊召唤的怪兽攻击力变成2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk*2)
		tc:RegisterEffect(e1)
		-- 这个回合的结束阶段回到持有者手卡。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetOperation(c78552773.retop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 结束阶段回到手卡的效果处理函数
function c78552773.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将该怪兽送回持有者的手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
