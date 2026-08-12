--超騎甲虫アブソリュート・ヘラクレス
-- 效果：
-- 昆虫族怪兽×4
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合，这张卡直到下次的自己回合的结束时不受其他卡的效果影响。
-- ②：自己·对方的战斗阶段结束时，以自己墓地1只攻击力3000以下的昆虫族怪兽为对象才能发动。那只怪兽特殊召唤。
function c50855622.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用4个昆虫族怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),4,true)
	-- ①：这张卡融合召唤成功的场合，这张卡直到下次的自己回合的结束时不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c50855622.regcon)
	e1:SetOperation(c50855622.regop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段结束时，以自己墓地1只攻击力3000以下的昆虫族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50855622,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1,50855622)
	e2:SetTarget(c50855622.sptg)
	e2:SetOperation(c50855622.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为融合召唤成功
function c50855622.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 创建免疫效果，使自身在融合召唤成功后直到下次自己回合结束时不受其他卡的效果影响
function c50855622.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置效果免疫的对象为除自身外的所有效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c50855622.efilter)
	-- 判断当前回合玩家是否为自己
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	e:GetHandler():RegisterEffect(e1)
end
-- 返回效果的拥有者不是自身的效果
function c50855622.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 过滤满足条件的怪兽：昆虫族、攻击力3000以下且可特殊召唤
function c50855622.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsAttackBelow(3000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标时的过滤条件，确保选择的是墓地中的昆虫族且攻击力3000以下的怪兽
function c50855622.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50855622.spfilter(chkc,e,tp) end
	-- 检查是否有足够的场上空间和符合条件的目标怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认是否存在满足条件的墓地怪兽
		and Duel.IsExistingTarget(c50855622.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽，从己方墓地中选择一只符合条件的怪兽
	local g=Duel.SelectTarget(tp,c50855622.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，指定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将选中的怪兽特殊召唤到场上
function c50855622.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
