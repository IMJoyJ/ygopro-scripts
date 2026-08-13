--星遺物を継ぐもの
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只怪兽为对象才能发动。那只怪兽在作为场上的连接怪兽所连接区的自己场上特殊召唤。
function c99674361.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只怪兽为对象才能发动。那只怪兽在作为场上的连接怪兽所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,99674361+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c99674361.target)
	e1:SetOperation(c99674361.activate)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤筛选函数：检查怪兽c能否被玩家tp以表侧表示特殊召唤到zone区域（正常检查召唤条件与苏生限制）。
function c99674361.filter(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果发动时的目标选择处理：获取连接区域；若指定对象则验证其位于自己墓地且满足特殊召唤条件；若为发动时点则检查场上是否有空位以及墓地是否存在可选对象。
function c99674361.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取己方场上由连接怪兽所指向的连接区域（可作为特殊召唤的场所）。
	local zone=Duel.GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c99674361.filter(chkc,e,tp,zone) end
	-- 效果发动时（chk==0）检查自己场上是否存在可用的怪兽区域空格（主怪兽区或额外怪兽区至少有一个空位）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查墓地是否存在至少1只能够满足特殊召唤条件并被选为对象的怪兽。
		and Duel.IsExistingTarget(c99674361.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的怪兽作为效果对象，并设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c99674361.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 登记操作信息：本次效果包含特殊召唤，对象为所选择的怪兽g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的操作：取得对象怪兽，获取当前连接区域，若对象仍与此效果关联且存在可用连接区域，则将其特殊召唤。
function c99674361.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 获取当前己方的连接区域，用于决定特殊召唤的位置。
	local zone=Duel.GetLinkedZone(tp)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己的连接区域（zone），并正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
