--デブリ・ドラゴン
-- 效果：
-- 把这张卡作为同调素材的场合，不是龙族怪兽的同调召唤不能使用，其他的同调素材怪兽必须全部是4星以外的怪兽。
-- ①：这张卡召唤成功时，以自己墓地1只攻击力500以下的怪兽为对象才能发动。那只怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c14943837.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是龙族怪兽的同调召唤不能使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c14943837.synlimit)
	c:RegisterEffect(e1)
	-- 其他的同调素材怪兽必须全部是4星以外的怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetTarget(c14943837.synlimit2)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功时，以自己墓地1只攻击力500以下的怪兽为对象才能发动。那只怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14943837,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c14943837.sumtg)
	e3:SetOperation(c14943837.sumop)
	c:RegisterEffect(e3)
end
-- 判断同调素材是否为龙族，非龙族则不能作为同调素材
function c14943837.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_DRAGON)
end
-- 判断同调素材是否为4星，是4星则不能作为同调素材
function c14943837.synlimit2(e,c)
	return not c:IsLevel(4)
end
-- 筛选墓地攻击力不超过500且可以攻击表示特殊召唤的怪兽
function c14943837.filter2(c,e,sp)
	return c:IsAttackBelow(500) and c:IsCanBeSpecialSummoned(e,0,sp,false,false,POS_FACEUP_ATTACK)
end
-- 设置效果处理时的条件判断和目标选择逻辑
function c14943837.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14943837.filter2(chkc,e,tp) end
	-- 判断是否满足特殊召唤的条件，包括场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在符合条件的墓地怪兽作为目标
		and Duel.IsExistingTarget(c14943837.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择符合条件的墓地怪兽作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,c14943837.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置效果发动后的处理函数
function c14943837.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在场并执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 为特殊召唤的怪兽设置效果无效化（技能抽取）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 为特殊召唤的怪兽设置效果永久无效化（直到回合结束）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
