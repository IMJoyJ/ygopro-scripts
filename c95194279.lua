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
-- 效果发动条件判定：自己墓地没有卡存在
function c95194279.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地的卡片数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)==0
end
-- 过滤自己除外区可特殊召唤的表侧表示怪兽
function c95194279.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动取对象及操作信息设置
function c95194279.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c95194279.filter(chkc,e,tp) end
	-- 检查怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在可成为对象的怪兽
		and Duel.IsExistingTarget(c95194279.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己除外区1只怪兽作为对象
	local g=Duel.SelectTarget(tp,c95194279.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将目标怪兽特殊召唤到自己场上
function c95194279.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
