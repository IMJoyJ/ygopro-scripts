--マリスボラス・スプーン
-- 效果：
-- 这张卡在场上表侧表示存在的场合「食恶餐匙鬼」以外的名字带有「食恶」的怪兽在自己场上召唤·特殊召唤时，可以从自己墓地选择1只恶魔族·2星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「食恶餐匙鬼」的效果1回合只能使用1次。
function c35307484.initial_effect(c)
	-- 这张卡在场上表侧表示存在的场合，「食恶餐匙鬼」以外的名字带有「食恶」的怪兽在自己场上召唤·特殊召唤时，可以从自己墓地选择1只恶魔族·2星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「食恶餐匙鬼」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35307484,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,35307484)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c35307484.condition)
	e1:SetTarget(c35307484.target)
	e1:SetOperation(c35307484.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：判断召唤/特殊召唤的怪兽是否为表侧表示、由tp控制、属于「食恶」系列且不是「食恶餐匙鬼」本卡。
function c35307484.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x8b) and not c:IsCode(35307484)
end
-- 发动条件判定：当「食恶餐匙鬼」以外的名字带有「食恶」的怪兽被召唤·特殊召唤时（该怪兽不是这张卡自身），本效果可以发动。
function c35307484.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c35307484.cfilter,1,nil,tp)
end
-- 特殊召唤对象筛选：选择墓地中1只等级2、种族为恶魔族、且可以被特殊召唤的怪兽。
function c35307484.spfilter(c,e,tp)
	return c:IsLevel(2) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标处理：确认自己场上有空位，并从墓地选择1只符合条件的恶魔族·2星怪兽作为特殊召唤的对象。
function c35307484.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c35307484.spfilter(chkc,e,tp) end
	-- 发动合法性检查：自己主要怪兽区域必须存在至少1个空格才能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在至少1只满足条件的恶魔族·2星怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c35307484.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只符合条件的恶魔族·2星怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c35307484.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，标明本次效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽以表侧表示特殊召唤到己方场上，并使其效果无效化。
function c35307484.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区域有空位，若没有则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取效果发动时选择的特召对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果相关，并将其作为特殊召唤步骤以表侧表示特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成连锁中的特殊召唤步骤，触发特殊召唤成功相关时点。
	Duel.SpecialSummonComplete()
end
