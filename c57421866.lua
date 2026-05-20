--レベル・スティーラー
-- 效果：
-- ①：这张卡只要在怪兽区域存在，不能为上级召唤以外而解放。
-- ②：这张卡在墓地存在的场合，以自己场上1只5星以上的怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡从墓地特殊召唤。
function c57421866.initial_effect(c)
	-- ②：这张卡在墓地存在的场合，以自己场上1只5星以上的怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57421866,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(c57421866.target)
	e1:SetOperation(c57421866.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡只要在怪兽区域存在，不能为上级召唤以外而解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示且等级在5星以上的怪兽
function c57421866.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
-- 效果2的发动合法性检测与对象选择
function c57421866.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c57421866.filter(chkc) end
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1只满足条件的5星以上的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c57421866.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否有空余的怪兽区域，且这张卡是否能特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择1只5星以上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(57421866,1))  --"请选择的1只5星以上的怪兽"
	-- 选择自己场上1只表侧表示且5星以上的怪兽作为效果对象
	Duel.SelectTarget(tp,c57421866.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果2的效果处理（使对象怪兽等级下降1星，并将这张卡特殊召唤）
function c57421866.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:GetLevel()<2 then return end
	local c=e:GetHandler()
	-- 那只怪兽的等级下降1星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-1)
	tc:RegisterEffect(e1)
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
