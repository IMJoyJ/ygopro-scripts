--天雷震龍－サンダー・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。雷族怪兽的效果在手卡发动的回合，从手卡以及自己场上的表侧表示怪兽之中把1只8星以下的雷族怪兽除外的场合可以特殊召唤。
-- ①：对方回合1次，从自己墓地把包含雷族怪兽的2张卡除外，以自己场上1只雷族怪兽为对象才能发动。这个回合，那只怪兽不会成为对方的效果的对象。
-- ②：自己结束阶段才能发动。从卡组把1张「雷龙」卡送去墓地。
function c5206415.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：对方回合1次，从自己墓地把包含雷族怪兽的2张卡除外，以自己场上1只雷族怪兽为对象才能发动。这个回合，那只怪兽不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c5206415.spcon)
	e1:SetTarget(c5206415.sptg)
	e1:SetOperation(c5206415.spop)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段才能发动。从卡组把1张「雷龙」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5206415,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c5206415.etcon)
	e2:SetCost(c5206415.etcost)
	e2:SetTarget(c5206415.ettg)
	e2:SetOperation(c5206415.etop)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤。雷族怪兽的效果在手卡发动的回合，从手卡以及自己场上的表侧表示怪兽之中把1只8星以下的雷族怪兽除外的场合可以特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5206415,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c5206415.tgcon)
	e3:SetTarget(c5206415.tgtg)
	e3:SetOperation(c5206415.tgop)
	c:RegisterEffect(e3)
	-- 设置操作类型为发动效果、代号为5206415的计数器
	Duel.AddCustomActivityCounter(5206415,ACTIVITY_CHAIN,c5206415.chainfilter)
end
-- 过滤函数，以Card类型为参数，返回值为false的卡片进行以下类型的操作，计数器增加1（目前最多为1）
function c5206415.chainfilter(re,tp,cid)
	return not (re:GetHandler():IsRace(RACE_THUNDER) and re:IsActiveType(TYPE_MONSTER)
		-- 连锁发生位置所属玩家为手牌时
		and Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_HAND)
end
-- 满足条件的卡必须是表侧表示或在手牌、等级8以下、雷族、可作为除外费用、场上怪兽区数量大于0
function c5206415.spfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsLevelBelow(8) and c:IsRace(RACE_THUNDER)
		-- 满足条件的卡必须是可作为除外费用、场上怪兽区数量大于0
		and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动条件：己方或对方有发动过连锁且场上有满足条件的卡
function c5206415.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 己方有发动过连锁
	return (Duel.GetCustomActivityCount(5206415,tp,ACTIVITY_CHAIN)~=0
		-- 对方有发动过连锁
		or Duel.GetCustomActivityCount(5206415,1-tp,ACTIVITY_CHAIN)~=0)
		-- 场上有满足条件的卡
		and Duel.IsExistingMatchingCard(c5206415.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c,tp)
end
-- 获取满足条件的卡组并提示选择一张卡除外
function c5206415.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的卡组
	local g=Duel.GetMatchingGroup(c5206415.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c,tp)
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 将选中的卡除外
function c5206415.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 效果发动条件：当前回合为对方回合
function c5206415.etcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 检查子组中是否存在雷族怪兽
function c5206415.fselect(g)
	return g:IsExists(Card.IsRace,1,nil,RACE_THUNDER)
end
-- 支付除外费用：从墓地选择2张包含雷族怪兽的卡除外
function c5206415.etcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取可作为除外费用的卡组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(c5206415.fselect,2,2) end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,c5206415.fselect,false,2,2)
	-- 将选中的卡除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 满足条件的卡必须是表侧表示且为雷族
function c5206415.etfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 设置效果对象：选择己方场上一只雷族怪兽
function c5206415.ettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c5206415.etfilter(chkc) end
	-- 检查是否有满足条件的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(c5206415.etfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择效果对象
	Duel.SelectTarget(tp,c5206415.etfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将效果应用到目标怪兽上，使其在本回合不会成为对方的效果的对象
function c5206415.etop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 设置效果：使目标怪兽在本回合不会成为对方的效果的对象
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetValue(c5206415.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end
-- 返回值为对方玩家编号
function c5206415.tgoval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
-- 效果发动条件：当前回合为己方回合
function c5206415.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合为己方回合
	return Duel.GetTurnPlayer()==tp
end
-- 满足条件的卡必须是雷龙卡组且可送去墓地
function c5206415.tgfilter(c)
	return c:IsSetCard(0x11c) and c:IsAbleToGrave()
end
-- 设置效果处理信息，确定要处理的效果分类为送去墓地
function c5206415.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c5206415.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，确定要处理的效果分类为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 选择一张雷龙卡送去墓地
function c5206415.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c5206415.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
