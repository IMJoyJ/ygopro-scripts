--早すぎた復活
-- 效果：
-- 选择自己墓地存在的1只名字带有「地缚神」的怪兽发动。选择的怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在那个回合不能攻击宣言。此外，这个效果特殊召唤的怪兽进行战斗的场合，对方玩家受到的战斗伤害变成0。
function c39967326.initial_effect(c)
	-- 效果发动时点为自由时点，效果分类为特殊召唤，效果属性为取对象，效果类型为发动，效果提示时点为结束阶段开始时点
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c39967326.target)
	e1:SetOperation(c39967326.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选名字带有「地缚神」且可以特殊召唤的怪兽
function c39967326.filter(c,e,tp)
	return c:IsSetCard(0x1021) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时点的目标选择函数，用于选择满足条件的墓地怪兽作为对象
function c39967326.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39967326.filter(chkc,e,tp) end
	-- 判断是否满足特殊召唤的条件，即玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否在墓地存在满足条件的怪兽
		and Duel.IsExistingTarget(c39967326.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c39967326.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，用于执行特殊召唤及后续效果
function c39967326.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍然存在于场上并执行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽在那个回合不能攻击宣言
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽进行战斗的场合，对方玩家受到的战斗伤害变成0
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
