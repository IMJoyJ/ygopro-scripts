--銀河暴竜
-- 效果：
-- 自己场上的名字带有「银河」的怪兽被选择作为攻击对象时才能发动。这张卡从手卡表侧守备表示特殊召唤。这个效果特殊召唤成功时，可以只用自己场上的名字带有「银河」的怪兽为素材，把1只名字带有「银河」的超量怪兽超量召唤。
function c24658418.initial_effect(c)
	-- 自己场上的名字带有「银河」的怪兽被选择作为攻击对象时才能发动。这张卡从手卡表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24658418,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c24658418.condition)
	e1:SetTarget(c24658418.target)
	e1:SetOperation(c24658418.operation)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，可以只用自己场上的名字带有「银河」的怪兽为素材，把1只名字带有「银河」的超量怪兽超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24658418,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c24658418.spcon)
	e2:SetTarget(c24658418.sptg)
	e2:SetOperation(c24658418.spop)
	c:RegisterEffect(e2)
end
-- 判断攻击对象是否为己方场上名字带有「银河」的怪兽且处于表侧表示
function c24658418.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选为攻击对象的怪兽
	local at=Duel.GetAttackTarget()
	return at:IsFaceup() and at:IsControler(tp) and at:IsSetCard(0x7b)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位以及此卡是否能被特殊召唤
function c24658418.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将此卡以表侧守备形式特殊召唤到场上
function c24658418.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧守备形式特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 确认此卡是否为特殊召唤成功
function c24658418.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 筛选场上名字带有「银河」且处于表侧表示的怪兽
function c24658418.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7b) and not c:IsType(TYPE_TOKEN)
end
-- 筛选名字带有「银河」且能使用指定素材进行XYZ召唤的超量怪兽
function c24658418.xyzfilter(c,mg)
	return c:IsSetCard(0x7b) and c:IsXyzSummonable(mg)
end
-- 判断是否满足超量召唤条件，即场上有名字带有「银河」的超量怪兽可被召唤
function c24658418.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取场上名字带有「银河」的怪兽
		local g=Duel.GetMatchingGroup(c24658418.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查额外卡组中是否存在名字带有「银河」且能使用上述怪兽作为素材的超量怪兽
		return Duel.IsExistingMatchingCard(c24658418.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
	end
	-- 设置超量召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行超量召唤操作，选择一只超量怪兽并使用场上怪兽作为素材进行XYZ召唤
function c24658418.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上名字带有「银河」的怪兽
	local g=Duel.GetMatchingGroup(c24658418.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中名字带有「银河」且能使用上述怪兽作为素材的超量怪兽
	local xyzg=Duel.GetMatchingGroup(c24658418.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 使用选定的超量怪兽和场上怪兽进行XYZ召唤
		Duel.XyzSummon(tp,xyz,g,1,5)
	end
end
