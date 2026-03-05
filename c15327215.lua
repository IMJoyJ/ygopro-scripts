--六武衆の真影
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己对「影六武众」怪兽的召唤·特殊召唤成功时才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，从自己墓地把1只4星以下的「六武众」怪兽除外才能发动。直到回合结束时，这张卡的属性·等级·攻击力·守备力变成和除外的那只怪兽相同。
function c15327215.initial_effect(c)
	-- ①：自己对「影六武众」怪兽的召唤·特殊召唤成功时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15327215,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,15327215)
	e1:SetCondition(c15327215.spcon)
	e1:SetTarget(c15327215.sptg)
	e1:SetOperation(c15327215.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从自己墓地把1只4星以下的「六武众」怪兽除外才能发动。直到回合结束时，这张卡的属性·等级·攻击力·守备力变成和除外的那只怪兽相同。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15327215,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c15327215.cost)
	e3:SetOperation(c15327215.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否有自己召唤的「影六武众」怪兽
function c15327215.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSetCard(0x903d)
end
-- 效果条件，判断是否有自己召唤或特殊召唤成功的「影六武众」怪兽
function c15327215.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15327215.cfilter,1,nil,tp)
end
-- 设置特殊召唤的处理目标
function c15327215.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数
function c15327215.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于选择墓地里4星以下的「六武众」怪兽作为除外对象
function c15327215.filter(c,mc)
	return c:IsLevelBelow(4) and c:IsSetCard(0x103d) and c:IsAbleToRemoveAsCost()
		and not (c:IsLevel(mc:GetLevel()) and c:IsAttribute(mc:GetAttribute()) and c:IsAttack(mc:GetAttack()) and c:IsDefense(mc:GetDefense()))
end
-- 效果发动时的处理函数，用于选择并除外墓地中的怪兽
function c15327215.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c15327215.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽并设置为除外对象
	local g=Duel.SelectMatchingCard(tp,c15327215.filter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	-- 将选中的怪兽从墓地除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 效果发动后的处理函数，用于改变此卡的属性、等级、攻击力和守备力
function c15327215.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local lv=tc:GetLevel()
		local att=tc:GetAttribute()
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 将此卡的等级修改为除外怪兽的等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(att)
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(atk)
		c:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e4:SetValue(def)
		c:RegisterEffect(e4)
	end
end
