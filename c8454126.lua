--ネフティスの繋ぎ手
-- 效果：
-- 「奈芙提斯的轮回」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡仪式召唤成功的场合才能发动。从手卡·卡组把「奈芙提斯之联结者」以外的1只「奈芙提斯」仪式怪兽当作仪式召唤作特殊召唤。
-- ②：这张卡被「奈芙提斯」卡的效果所解放的场合或者所破坏的场合才能发动。下次的准备阶段，从自己的手卡·卡组·场上各选最多1张仪式怪兽以外的「奈芙提斯」卡破坏。
function c8454126.initial_effect(c)
	-- 为怪兽注册记载特定卡牌代码「奈芙提斯的轮回」的关联列表
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
-- 判断特殊召唤效果的发动条件，须为这张卡成功仪式召唤
function c8454126.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤手牌或卡组中除「奈芙提斯之联结者」以外，且可以当作仪式召唤特殊召唤的「奈芙提斯」仪式怪兽
function c8454126.spfilter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsType(TYPE_RITUAL) and not c:IsCode(8454126) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
-- 特殊召唤效果的靶向，检测手牌和卡组中是否存在可特殊召唤的目标，并注册特殊召唤操作信息
function c8454126.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则先确认自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认自己的手牌或卡组中存在至少1只符合特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c8454126.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手牌或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的操作空间，从手牌或卡组选择怪兽并将其当作仪式召唤特殊召唤到场上
function c8454126.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无空余怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或卡组中选择1只满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c8454126.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选定的仪式怪兽以正面向上的表侧表示特殊召唤，且由于特殊召唤类型参数指定而视为仪式召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 判断破坏效果的发动条件，须为这张卡被「奈芙提斯」卡片的效果所解放或所破坏
function c8454126.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and re:GetHandler():IsSetCard(0x11f)
end
-- 破坏效果的发动阶段处理，为全局注册一个在下次准备阶段触发的延迟破坏效果
function c8454126.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 下次的准备阶段，从自己的手卡·卡组·场上各选最多1张仪式怪兽以外的「奈芙提斯」卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	-- 若当前阶段已经为准备阶段，则需要处理准备阶段中被触发的延迟破坏判断逻辑
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前的回合数记录为效果的标签值，以便于准确在下次准备阶段触发效果
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	else
		e1:SetLabel(0)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	end
	e1:SetCondition(c8454126.descon2)
	e1:SetTarget(c8454126.destg2)
	e1:SetOperation(c8454126.desop2)
	-- 将设定的阶段性持续效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断延迟破坏效果的触发时机，确保在下个回合的准备阶段触发效果
function c8454126.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前的回合数是否与记录的效果标签值不同，以确保满足「下次的准备阶段」
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 过滤手牌、卡组或场上仪式怪兽以外的「奈芙提斯」卡片
function c8454126.desfilter(c)
	return not (c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)) and c:IsSetCard(0x11f) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_DECK))
end
-- 延迟破坏效果的靶向判定，检查手牌、卡组及场上是否存在可破坏的卡片
function c8454126.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则确认手牌、卡组或场上是否存在至少1张可被破坏的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c8454126.desfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil) end
end
-- 检查所选择的卡片组合，限制每个区域（手牌、卡组、场上）最多只能选择1张卡片
function c8454126.fselect(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)<=1
end
-- 延迟破坏效果的具体处理，从手牌、卡组、场上各选最多1张符合条件的卡破坏
function c8454126.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向场上展示并发动「奈芙提斯之联结者」的卡片效果动画
	Duel.Hint(HINT_CARD,0,8454126)
	-- 获取手牌、卡组及自己场上所有可破坏的非仪式「奈芙提斯」卡片
	local g=Duel.GetMatchingGroup(c8454126.desfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,nil)
	-- 向玩家发送选择需要破坏卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:SelectSubGroup(tp,c8454126.fselect,false,1,3)
	-- 以效果破坏的形式将玩家选择的卡片破坏并送去墓地
	Duel.Destroy(sg,REASON_EFFECT)
end
