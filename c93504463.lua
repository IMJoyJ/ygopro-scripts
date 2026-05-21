--進化への懸け橋
-- 效果：
-- 自己场上存在的怪兽被选择作为攻击对象时才能发动。选择自己墓地存在的1只名字带有「进化虫」的怪兽特殊召唤，把攻击对象转换为那只怪兽进行伤害计算。
function c93504463.initial_effect(c)
	-- 自己场上存在的怪兽被选择作为攻击对象时才能发动。选择自己墓地存在的1只名字带有「进化虫」的怪兽特殊召唤，把攻击对象转换为那只怪兽进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c93504463.condition)
	e1:SetTarget(c93504463.target)
	e1:SetOperation(c93504463.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己场上的怪兽被选择作为攻击对象
function c93504463.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp)
end
-- 过滤条件：自己墓地中名字带有「进化虫」且可以特殊召唤的怪兽
function c93504463.spfilter(c,e,tp)
	return c:IsSetCard(0x304e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查
function c93504463.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93504463.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「进化虫」怪兽
		and Duel.IsExistingTarget(c93504463.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「进化虫」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c93504463.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤目标怪兽，并将攻击对象转移至该怪兽进行伤害计算
function c93504463.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍与效果相关，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取进行攻击的怪兽
		local a=Duel.GetAttacker()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 强制让攻击怪兽与特殊召唤的怪兽进行伤害计算
			Duel.CalculateDamage(a,tc)
		end
	end
end
