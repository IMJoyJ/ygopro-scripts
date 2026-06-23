--ガスタの賢者 ウィンダール
-- 效果：
-- 这张卡战斗破坏怪兽送去墓地时，可以把自己墓地存在的1只3星以下的名字带有「薰风」的怪兽表侧守备表示特殊召唤。
function c27944249.initial_effect(c)
	-- 这张卡战斗破坏怪兽送去墓地时，可以把自己墓地存在的1只3星以下的名字带有「薰风」的怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27944249,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测是否为战斗破坏对方怪兽送去墓地的时点
	e1:SetCondition(aux.bdgcon)
	e1:SetTarget(c27944249.target)
	e1:SetOperation(c27944249.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的墓地怪兽：等级3以下、名字带有「薰风」、可以特殊召唤
function c27944249.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果的目标选择条件：选择满足filter条件的墓地怪兽
function c27944249.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27944249.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c27944249.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c27944249.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果的处理信息：将特殊召唤的怪兽加入连锁处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选中的怪兽特殊召唤
function c27944249.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
