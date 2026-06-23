--ブラック・バック
-- 效果：
-- 自己回合才能发动。选择自己墓地存在的1只攻击力2000以下的名字带有「黑羽」的怪兽特殊召唤。这张卡发动的回合，自己不能把怪兽通常召唤。
function c44028461.initial_effect(c)
	-- 创建卡的效果，设置为发动时点，条件为己方回合，费用为不能通常召唤，目标为墓地攻击力2000以下的黑羽怪兽，效果为特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c44028461.condition)
	e1:SetCost(c44028461.cost)
	e1:SetTarget(c44028461.target)
	e1:SetOperation(c44028461.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：必须在自己回合才能发动。
function c44028461.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果使用者。
	return Duel.GetTurnPlayer()==tp
end
-- 效果的费用：在发动回合不能进行通常召唤。
function c44028461.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在当前回合是否已经进行过通常召唤。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
	-- 创建一个不能召唤怪兽的效果并注册给对方玩家。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将不能召唤怪兽的效果注册给当前玩家。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 创建一个不能覆盖怪兽的效果并注册给当前玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 筛选满足条件的怪兽：攻击力2000以下，黑羽卡组，怪兽类型，可特殊召唤。
function c44028461.filter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标：选择自己墓地满足条件的怪兽。
function c44028461.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c44028461.filter(chkc,e,tp) end
	-- 判断场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c44028461.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c44028461.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将目标怪兽特殊召唤。
function c44028461.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
