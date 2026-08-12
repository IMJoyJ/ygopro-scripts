--海皇の狙撃兵
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，可以从卡组把「海皇的狙击兵」以外的1只4星以下的名字带有「海皇」的海龙族怪兽特殊召唤。此外，这张卡为让水属性怪兽的效果发动而被送去墓地时，选择对方场上盖放的1张卡破坏。
function c706925.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害时，可以从卡组把「海皇的狙击兵」以外的1只4星以下的名字带有「海皇」的海龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(706925,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c706925.spcon)
	e1:SetTarget(c706925.sptg)
	e1:SetOperation(c706925.spop)
	c:RegisterEffect(e1)
	-- 此外，这张卡为让水属性怪兽的效果发动而被送去墓地时，选择对方场上盖放的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(706925,1))  --"盖卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c706925.descon)
	e2:SetTarget(c706925.destg)
	e2:SetOperation(c706925.desop)
	c:RegisterEffect(e2)
end
-- 检查造成战斗伤害的对象是否为对方玩家。
function c706925.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 过滤卡组中不为「海皇的狙击兵」、等级4以下、属于「海皇」系列、海龙族且可以特殊召唤的怪兽。
function c706925.spfilter(c,e,tp)
	return not c:IsCode(706925) and c:IsLevelBelow(4) and c:IsSetCard(0x77) and c:IsRace(RACE_SEASERPENT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与合法性检查。
function c706925.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，检查卡组中是否存在至少1张满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c706925.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的效果处理。
function c706925.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无可用怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c706925.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查此卡是否作为水属性怪兽发动效果的代价而被送去墓地。
function c706925.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤场上里侧表示（盖放）的卡。
function c706925.desfilter(c)
	return c:IsFacedown()
end
-- 破坏盖卡效果的发动准备，选择对方场上1张盖放的卡作为效果对象。
function c706925.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c706925.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张里侧表示的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c706925.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏的操作信息，表示将破坏所选的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏盖卡效果的效果处理。
function c706925.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中被选为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 因效果将该对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
