--ミス・リバイブ
-- 效果：
-- 选择对方墓地1只怪兽才能发动。选择的怪兽在对方场上表侧守备表示特殊召唤。
function c83778600.initial_effect(c)
	-- 选择对方墓地1只怪兽才能发动。选择的怪兽在对方场上表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83778600.target)
	e1:SetOperation(c83778600.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方墓地中可以被特殊召唤到对方场上且表示形式为表侧守备表示的怪兽
function c83778600.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- 效果发动的靶向检测，判断对方场上是否有怪兽区域空位，以及对方墓地中是否存在符合条件的目标
function c83778600.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c83778600.filter(chkc,e,tp) end
	-- 检查对方场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 检查对方墓地中是否存在至少1只可以特殊召唤的目标怪兽
		and Duel.IsExistingTarget(c83778600.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地中1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c83778600.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息，声明该效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理，获取对象怪兽，并在其仍与效果相关的情况下，将其在对方场上表侧守备表示特殊召唤
function c83778600.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选择为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在对方场上表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
