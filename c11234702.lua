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
	-- 将此卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c11234702.lvtg)
	e3:SetOperation(c11234702.lvop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的墓地怪兽
function c11234702.spfilter(c,e,tp)
	return c:IsSetCard(0x27) and c:IsLevelBelow(4) and not c:IsCode(11234702) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果①的发动时的取对象步骤
function c11234702.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11234702.spfilter(chkc,e,tp) end
	-- 判断是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤的条件
		and Duel.IsExistingTarget(c11234702.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c11234702.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果①的发动时的处理步骤
function c11234702.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效并进行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断场上是否满足等级调整的条件
function c11234702.filter(c)
	return c:IsSetCard(0x27) and c:IsFaceup() and c:GetLevel()>0
end
-- 处理效果②的发动时的取对象步骤
function c11234702.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11234702.filter(chkc) end
	-- 判断是否满足等级调整的条件
	if chk==0 then return Duel.IsExistingTarget(c11234702.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要调整等级的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择满足条件的场上怪兽作为等级调整对象
	Duel.SelectTarget(tp,c11234702.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果②的发动时的处理步骤
function c11234702.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			-- 选择等级上升或下降
			sel=Duel.SelectOption(tp,aux.Stringid(11234702,1))  --"等级上升1星"
		else
			-- 选择等级上升或下降
			sel=Duel.SelectOption(tp,aux.Stringid(11234702,1),aux.Stringid(11234702,2))  --"等级上升1星" / "等级下降1星"
		end
		if sel==1 then
			lvl=-1
		end
		-- 使目标怪兽的等级上升或下降1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
