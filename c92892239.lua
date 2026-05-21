--ヴァレルロード・F・ドラゴン
-- 效果：
-- 龙族·暗属性怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，以自己场上1只怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
-- ②：把墓地的这张卡除外，以自己墓地1只暗属性连接怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
function c92892239.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤手续，需要2只满足过滤条件的怪兽作为素材
	aux.AddFusionProcFunRep(c,c92892239.ffilter,2,true)
	-- ①：自己·对方回合，以自己场上1只怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92892239,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,92892239)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c92892239.destg)
	e1:SetOperation(c92892239.desop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只暗属性连接怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92892239,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,92892240)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置发动成本为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c92892239.sptg)
	e2:SetOperation(c92892239.spop)
	c:RegisterEffect(e2)
end
-- 融合素材的过滤条件：暗属性且是龙族的怪兽
function c92892239.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end
-- 效果①（破坏效果）的发动条件及对象选择
function c92892239.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以作为对象的卡
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽作为对象
	local g1=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为对象
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息为破坏这2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果①（破坏效果）的效果处理
function c92892239.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 因效果破坏这些卡
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 效果②特殊召唤的过滤条件：自己墓地的暗属性连接怪兽
function c92892239.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（特殊召唤）的发动条件及对象选择
function c92892239.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c92892239.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的暗属性连接怪兽
		and Duel.IsExistingTarget(c92892239.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的暗属性连接怪兽作为对象
	local g=Duel.SelectTarget(tp,c92892239.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②（特殊召唤）的效果处理
function c92892239.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
