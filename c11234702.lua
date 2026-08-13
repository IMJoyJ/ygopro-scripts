--TG スクリュー・サーペント
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以除「科技属 螺旋桨蛇」外的自己墓地1只4星以下的「科技属」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：把墓地的这张卡除外，以自己场上1只「科技属」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或下降1星。
function c11234702.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以除「科技属 螺旋桨蛇」外的自己墓地1只4星以下的「科技属」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,11234702)
	e1:SetTarget(c11234702.sptg)
	e1:SetOperation(c11234702.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上1只「科技属」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或下降1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11234702,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,11234703)
	-- 设置②效果的发动代价为把墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c11234702.lvtg)
	e3:SetOperation(c11234702.lvop)
	c:RegisterEffect(e3)
end
-- 定义①效果可选择的墓地怪兽的过滤条件：是「科技属」怪兽、4星以下、卡名不是「科技属 螺旋桨蛇」、且可以被特殊召唤。
function c11234702.spfilter(c,e,tp)
	return c:IsSetCard(0x27) and c:IsLevelBelow(4) and not c:IsCode(11234702) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件和取对象判定：若为连锁处理中检查对象，则确认选择的是自己墓地满足过滤条件的怪兽；若为发动时点（chk==0），则检查自己主要怪兽区是否有空位，且墓地存在满足条件的对象。
function c11234702.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11234702.spfilter(chkc,e,tp) end
	-- 发动时点检查自己场上主要怪兽区是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时点检查自己墓地是否存在满足特殊召唤条件的「科技属」怪兽作为效果对象。
		and Duel.IsExistingTarget(c11234702.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择要特殊召唤的卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter条件的「科技属」怪兽作为这个效果的对象。
	local g=Duel.SelectTarget(tp,c11234702.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将操作信息设置为“特殊召唤1只怪兽”，用于后续效果检测与连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，若其仍与效果关联，则将其表侧表示特殊召唤，并为其附加效果无效化处理，最后完成特殊召唤。
function c11234702.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果选择的对象怪兽（墓地中的「科技属」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，并尝试将其以表侧表示特殊召唤到自己的主要怪兽区；若成功则进入无效化处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，使通过SpecialSummonStep暂时特殊召唤的怪兽正式上场。
	Duel.SpecialSummonComplete()
end
-- 定义②效果可选择的对象过滤条件：自己场上表侧表示的「科技属」怪兽，且当前等级大于0。
function c11234702.filter(c)
	return c:IsSetCard(0x27) and c:IsFaceup() and c:GetLevel()>0
end
-- ②效果的取对象判定与发动条件：若为连锁处理中检查对象，则确认选择的是自己场上表侧表示且满足filter的怪兽；若为发动时点（chk==0），则检查自己场上是否存在满足条件的对象。
function c11234702.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11234702.filter(chkc) end
	-- 发动时点检查自己场上是否存在表侧表示且等级大于0的「科技属」怪兽，作为②效果的对象。
	if chk==0 then return Duel.IsExistingTarget(c11234702.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择效果对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上选择1只满足filter条件的「科技属」怪兽作为②效果的对象。
	Duel.SelectTarget(tp,c11234702.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：取得对象怪兽，若其仍与效果关联且表侧表示，则让玩家选择等级上升或下降1星，并应用等级变更效果直到回合结束。
function c11234702.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽（自己场上的「科技属」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			-- 当对象怪兽等级为1时，只能选择“等级上升1星”。
			sel=Duel.SelectOption(tp,aux.Stringid(11234702,1))  --"等级上升1星"
		else
			-- 当对象怪兽等级大于1时，可选择“等级上升1星”或“等级下降1星”。
			sel=Duel.SelectOption(tp,aux.Stringid(11234702,1),aux.Stringid(11234702,2))  --"等级上升1星/等级下降1星"
		end
		if sel==1 then
			lvl=-1
		end
		-- 那只怪兽的等级直到回合结束时上升或下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
