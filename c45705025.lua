--紋章獣ユニコーン
-- 效果：
-- 把墓地的这张卡从游戏中除外，选择自己墓地1只念动力族超量怪兽才能发动。选择的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「纹章兽 独角兽」的效果1回合只能使用1次。
function c45705025.initial_effect(c)
	-- 效果原文内容：把墓地的这张卡从游戏中除外，选择自己墓地1只念动力族超量怪兽才能发动。选择的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「纹章兽 独角兽」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45705025,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,45705025)
	-- 效果作用：支付将此卡从游戏中除外的费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c45705025.target)
	e1:SetOperation(c45705025.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：定义可用于选择的怪兽的过滤条件，必须是念动力族超量怪兽且可以特殊召唤
function c45705025.filter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置效果的目标选择逻辑，当chkc不为空时判断目标是否满足条件
function c45705025.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c45705025.filter(chkc,e,tp) end
	-- 效果作用：判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断自己墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c45705025.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 效果作用：向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c45705025.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 效果作用：设置连锁的操作信息，表明本次效果将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：处理效果的发动，执行特殊召唤并使召唤的怪兽效果无效
function c45705025.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断目标怪兽是否仍然存在于场上并执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 效果作用：完成特殊召唤流程，确保所有特殊召唤步骤结束
	Duel.SpecialSummonComplete()
end
