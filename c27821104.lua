--六武衆の荒行
-- 效果：
-- ①：以自己场上1只「六武众」怪兽为对象才能发动。和那只怪兽是卡名不同并是攻击力相同的1只「六武众」怪兽从卡组特殊召唤。作为对象的怪兽在这个回合的结束阶段破坏。
function c27821104.initial_effect(c)
	-- ①：以自己场上1只「六武众」怪兽为对象才能发动。和那只怪兽是卡名不同并是攻击力相同的1只「六武众」怪兽从卡组特殊召唤。作为对象的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27821104.target)
	e1:SetOperation(c27821104.activate)
	c:RegisterEffect(e1)
end
-- 卡组内候选怪兽的过滤条件：需为「六武众」，与对象怪兽卡名不同、攻击力相同，且能被当前效果特殊召唤。
function c27821104.tfilter(c,atk,code,e,tp)
	return c:IsSetCard(0x103d) and not c:IsCode(code) and c:IsAttack(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对象选择阶段的过滤条件：自己场上的表侧表示「六武众」怪兽，且卡组中存在满足上述条件的另一只「六武众」怪兽。
function c27821104.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		-- 确认卡组中存在至少1只与对象怪兽卡名不同、攻击力相同且可以特殊召唤的「六武众」怪兽。
		and Duel.IsExistingMatchingCard(c27821104.tfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttack(),c:GetCode(),e,tp)
end
-- 发动条件与取对象处理：检查自己场上有空位且存在符合条件的「六武众」怪兽，然后让玩家选择1只作为对象；连锁处理时验证对象合法性。
function c27821104.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c27821104.filter(chkc,e,tp) end
	-- 发动时合法性检查：确认己方主要怪兽区有可用空格，以便后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己场上存在至少1只满足条件的「六武众」怪兽可作为对象。
		and Duel.IsExistingTarget(c27821104.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家显示需要选择表侧表示怪兽的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只表侧表示的「六武众」怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c27821104.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果预定从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：确认有空格且对象仍合法后，从卡组选择符合条件的「六武众」怪兽特殊召唤，并为对象怪兽注册结束阶段破坏的效果。
function c27821104.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若己方主要怪兽区没有空位，则效果不处理（无法特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 向玩家显示需要选择特殊召唤的怪兽的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只与对象怪兽卡名不同、攻击力相同且可以特殊召唤的「六武众」怪兽。
	local sg=Duel.SelectMatchingCard(tp,c27821104.tfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetAttack(),tc:GetCode(),e,tp)
	if sg:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 作为对象的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetOperation(c27821104.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	tc:RegisterEffect(e1)
end
-- 结束阶段的破坏处理：破坏持有该效果的怪兽（即作为对象的怪兽）。
function c27821104.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将该怪兽破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
