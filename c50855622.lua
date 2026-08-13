--超騎甲虫アブソリュート・ヘラクレス
-- 效果：
-- 昆虫族怪兽×4
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合，这张卡直到下次的自己回合的结束时不受其他卡的效果影响。
-- ②：自己·对方的战斗阶段结束时，以自己墓地1只攻击力3000以下的昆虫族怪兽为对象才能发动。那只怪兽特殊召唤。
function c50855622.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：允许以4只昆虫族怪兽作为融合素材进行融合召唤（素材只需是昆虫族，不要求同名等额外条件）。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),4,true)
	-- ①：这张卡融合召唤成功的场合，这张卡直到下次的自己回合的结束时不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c50855622.regcon)
	e1:SetOperation(c50855622.regop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的战斗阶段结束时，以自己墓地1只攻击力3000以下的昆虫族怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 判定条件：这张卡是以融合召唤的方式特殊召唤成功；只有融合召唤成功时，才继续执行后面的免疫效果注册处理。
function c50855622.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 融合召唤成功时的处理：为这张卡注册一个免疫效果，使这张卡在主要怪兽区表侧表示期间不受对方卡的效果影响，并根据当前回合的情况持续到“下次自己的回合结束”。
function c50855622.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡直到下次的自己回合的结束时不受其他卡的效果影响。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c50855622.efilter)
	-- 判断当前回合玩家是否为本卡控制者，以决定免疫效果的持续设定：自己回合融合召唤时需跨到下次自己回合结束，对方回合融合召唤时则到下次自己回合结束即可。
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	e:GetHandler():RegisterEffect(e1)
end
-- 免疫效果的过滤函数：只有效果持有者与本卡持有者不同的效果才会被免疫，即本卡只不受对方卡的效果影响，自己的其他卡效果不会被免疫。
function c50855622.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 检索/选择墓地中可作为对象的怪兽：必须是昆虫族、攻击力3000以下，并且能够被当前效果特殊召唤（不检查召唤条件与苏生限制）。
function c50855622.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsAttackBelow(3000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性判定：若检查已选对象，则验证对象是否为自己墓地中满足特召条件的昆虫族怪兽；若进行发动检查，则要求自己场上有空位且墓地存在至少1只符合条件的昆虫族怪兽可选。
function c50855622.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50855622.spfilter(chkc,e,tp) end
	-- 发动检查时要求自己主要怪兽区有空余格位，用于后续特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动检查时还要求自己墓地中存在至少1只满足spfilter条件（昆虫族、攻击力3000以下、可特殊召唤）的怪兽作为对象，二者同时成立才能发动。
		and Duel.IsExistingTarget(c50855622.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示“请选择要特殊召唤的卡”，并将该提示写入选择缓存，供接下来的选卡界面使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足spfilter条件的昆虫族怪兽作为效果对象（取对象），并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c50855622.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理时的操作信息：宣告本次效果包含特殊召唤，预定的处理对象为刚选择的1张怪兽卡，供系统和其他卡的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取回发动时选择的对象怪兽，若该卡仍与效果关联，则将其表侧表示特殊召唤到己方场上，完成②效果的召唤处理。
function c50855622.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那1只对象怪兽（第一目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到己方场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
