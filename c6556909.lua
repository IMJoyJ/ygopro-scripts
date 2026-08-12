--真紅き魂
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次，③的效果在决斗中只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「真红眼黑龙」使用。
-- ②：对方把怪兽特殊召唤的场合，把手卡·场上的这张卡送去墓地才能发动。从手卡·卡组把「真红之魂」以外的1只「真红眼」怪兽特殊召唤。
-- ③：自己·对方回合，以自己场上1只「真红眼黑龙」为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c6556909.initial_effect(c)
	-- 设置这张卡在场上·墓地存在时，卡名当作「真红眼黑龙」使用
	aux.EnableChangeCode(c,74677422,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：对方把怪兽特殊召唤的场合，把手卡·场上的这张卡送去墓地才能发动。从手卡·卡组把「真红之魂」以外的1只「真红眼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,6556909)
	e1:SetCondition(c6556909.spcon)
	e1:SetCost(c6556909.spcost)
	e1:SetTarget(c6556909.sptg)
	e1:SetOperation(c6556909.spop)
	c:RegisterEffect(e1)
	-- ③：自己·对方回合，以自己场上1只「真红眼黑龙」为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,6556910+EFFECT_COUNT_CODE_DUEL)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(c6556909.damtg)
	e2:SetOperation(c6556909.damop)
	c:RegisterEffect(e2)
end
-- 效果②的发动条件：对方把怪兽特殊召唤的场合
function c6556909.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 效果②的代价检测与执行函数
function c6556909.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手卡·场上的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手卡·卡组中「真红之魂」以外的「真红眼」怪兽
function c6556909.spfilter(c,e,tp)
	return not c:IsCode(6556909) and c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动检测与效果注册函数
function c6556909.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身作为代价离场后，己方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手卡·卡组是否存在至少1只满足条件的「真红眼」怪兽
		and Duel.IsExistingMatchingCard(c6556909.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的效果处理函数
function c6556909.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只满足条件的「真红眼」怪兽
	local g=Duel.SelectMatchingCard(tp,c6556909.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：己方场上表侧表示的「真红眼黑龙」且原本攻击力大于0
function c6556909.damfilter(c)
	return c:IsFaceup() and c:IsCode(74677422) and c:GetBaseAttack()>0
end
-- 效果③的发动检测与效果注册函数
function c6556909.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c6556909.damfilter(chkc) end
	-- 检查己方场上是否存在可以作为对象的「真红眼黑龙」
	if chk==0 then return Duel.IsExistingTarget(c6556909.damfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择己方场上1只「真红眼黑龙」作为效果对象
	local g=Duel.SelectTarget(tp,c6556909.damfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- 效果③的效果处理函数
function c6556909.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给与对方该怪兽原本攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
