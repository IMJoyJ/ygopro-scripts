--奇跡の蘇生
-- 效果：
-- 连锁4以后才能发动。从墓地选择1只怪兽，在自己场上特殊召唤。同1组连锁上有复数次同名卡的效果发动的场合，这张卡不能发动。
function c37011715.initial_effect(c)
	-- 连锁4以后才能发动。从墓地选择1只怪兽，在自己场上特殊召唤。同1组连锁上有复数次同名卡的效果发动的场合，这张卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c37011715.condition)
	e1:SetTarget(c37011715.target)
	e1:SetOperation(c37011715.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：仅在当前连锁序号>2（即连锁4以后）且当前连锁中无同名卡效果发动时，效果才可发动。
function c37011715.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件：当前连锁序号>2（即连锁4以后）并且当前连锁内不存在同名卡效果的发动（满足同名卡限制）。
	return Duel.GetCurrentChain()>2 and Duel.CheckChainUniqueness()
end
-- 定义墓地怪兽的筛选条件：该怪兽可以被玩家tp通过此效果以通常规则特殊召唤（需满足召唤条件与苏生限制）。
function c37011715.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义发动时目标选择函数：先检查自己场上是否有空余的主要怪兽区，且墓地存在可被此效果特殊召唤并能成为对象的怪兽；满足后让玩家选择1只墓地怪兽作为对象，并注册特殊召唤的操作信息。
function c37011715.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c37011715.filter(chkc,e,tp) end
	-- 在效果发动时（chk==0）检查：玩家tp场上是否有至少1个可用的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在满足c37011715.filter条件且能被当前效果取为对象的怪兽（至少1只）。
		and Duel.IsExistingTarget(c37011715.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家tp显示提示文字“请选择要特殊召唤的卡”，用于卡片选择界面的标题。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从双方墓地选择1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c37011715.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息：本连锁效果处理时将进行1只怪兽的特殊召唤，供相关卡（如星尘龙、王家长眠之谷等）检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理函数：在效果处理时取得之前选择的对象怪兽，若该怪兽仍与效果关联，则将其特殊召唤到自己场上。
function c37011715.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中此效果选择的对象怪兽（唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到玩家tp自己场上，不指定特殊召唤类型（sumtype=0），需要正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
