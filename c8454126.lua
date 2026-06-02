--ネフティスの繋ぎ手
-- 效果：
-- 「奈芙提斯的轮回」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡仪式召唤成功的场合才能发动。从手卡·卡组把「奈芙提斯之联结者」以外的1只「奈芙提斯」仪式怪兽当作仪式召唤作特殊召唤。
-- ②：这张卡被「奈芙提斯」卡的效果所解放的场合或者所破坏的场合才能发动。下次的准备阶段，从自己的手卡·卡组·场上各选最多1张仪式怪兽以外的「奈芙提斯」卡破坏。
function c8454126.initial_effect(c)
	aux.AddCodeList(c,23459650)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。从手卡·卡组把「奈芙提斯之联结者」以外的1只「奈芙提斯」仪式怪兽当作仪式召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8454126,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,8454126)
	e1:SetCondition(c8454126.spcon)
	e1:SetTarget(c8454126.sptg)
	e1:SetOperation(c8454126.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被「奈芙提斯」卡的效果所解放的场合或者所破坏的场合才能发动。下次的准备阶段，从自己的手卡·卡组·场上各选最多1张仪式怪兽以外的「奈芙提斯」卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8454126,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,8454127)
	e2:SetCondition(c8454126.descon)
	e2:SetOperation(c8454126.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_DESTROYED)
	c:RegisterEffect(e3)
end
-- 检查此卡是否是通过仪式召唤特殊召唤成功的
function c8454126.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤手卡·卡组中除「奈芙提斯之联结者」以外的「奈芙提斯」仪式怪兽，且该怪兽可以被特殊召唤（当作仪式召唤）
function c8454126.spfilter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsType(TYPE_RITUAL) and not c:IsCode(8454126) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
-- 效果①的发动准备（检查怪兽区域是否有空位，以及手卡·卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息）
function c8454126.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1张满足过滤条件的「奈芙提斯」仪式怪兽
		and Duel.IsExistingMatchingCard(c8454126.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡或卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的处理（从手卡·卡组选择1只符合条件的「奈芙提斯」仪式怪兽，当作仪式召唤特殊召唤）
function c8454126.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组中选择1张符合条件的「奈芙提斯」仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c8454126.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的怪兽以仪式召唤的方式、表侧表示特殊召唤到自己场上（无视苏生限制）
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 检查此卡是否是因为「奈芙提斯」卡片的效果而被解放或破坏
function c8454126.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and re:GetHandler():IsSetCard(0x11f)
end
-- 效果②的发动处理（注册一个在下次准备阶段发动的延迟效果）
function c8454126.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 下次的准备阶段，从自己的手卡·卡组·场上各选最多1张仪式怪兽以外的「奈芙提斯」卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	-- 检查当前是否已经是准备阶段（用于处理在准备阶段发动此效果时，延迟到下个回合的准备阶段生效）
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前回合数记录在效果的Label中，以防止在当前回合的准备阶段立即触发
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	else
		e1:SetLabel(0)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	end
	e1:SetCondition(c8454126.descon2)
	e1:SetTarget(c8454126.destg2)
	e1:SetOperation(c8454126.desop2)
	-- 将该延迟效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 延迟效果的触发条件（确保不在注册该效果的当前回合的准备阶段立即触发）
function c8454126.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合数是否不等于记录的回合数（即必须是下一次准备阶段）
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 过滤仪式怪兽以外的「奈芙提斯」卡片（手卡·卡组中的卡，或场上表侧表示的卡）
function c8454126.desfilter(c)
	return not (c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)) and c:IsSetCard(0x11f) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_DECK))
end
-- 延迟效果的发动准备（检查手卡·卡组·场上是否存在至少1张符合条件的卡）
function c8454126.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡、卡组或场上是否存在至少1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8454126.desfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil) end
end
-- 限制选择的卡片组中，来自手卡、卡组、场上的卡片数量各不能超过1张
function c8454126.fselect(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)<=1
end
-- 延迟效果的实际处理（从手卡·卡组·场上各选最多1张仪式怪兽以外的「奈芙提斯」卡破坏）
function c8454126.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了「奈芙提斯之联结者」的效果
	Duel.Hint(HINT_CARD,0,8454126)
	-- 获取手卡、卡组及场上所有符合条件的「奈芙提斯」卡片
	local g=Duel.GetMatchingGroup(c8454126.desfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:SelectSubGroup(tp,c8454126.fselect,false,1,3)
	-- 破坏选中的卡片
	Duel.Destroy(sg,REASON_EFFECT)
end
