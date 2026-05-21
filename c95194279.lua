--次元の歪み
-- 效果：
-- 当自己的墓地里没有卡存在的场合这张卡才能发动。选择自己1只被除外的怪兽特殊召唤到自己场上。
function c95194279.initial_effect(c)
	-- 当自己的墓地里没有卡存在的场合这张卡才能发动。选择自己1只被除外的怪兽特殊召唤到自己场上。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c95194279.condition)
	e1:SetTarget(c95194279.target)
	e1:SetOperation(c95194279.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数：检查自己墓地是否存在卡片。
function c95194279.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己墓地的卡片数量是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)==0
end
-- 过滤条件：筛选可以被特殊召唤的怪兽。
function c95194279.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测（支持在连锁中作为效果对象被选择）。
function c95194279.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c95194279.filter(chkc,e,tp) end
	-- 在发动阶段，首先检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己被除外的卡中存在至少1只可以特殊召唤的怪兽。
		and Duel.IsExistingTarget(c95194279.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发送提示信息：选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己1只被除外的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c95194279.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，表明此效果包含特殊召唤分类，对象为选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选择的对象怪兽特殊召唤。
function c95194279.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动者的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
