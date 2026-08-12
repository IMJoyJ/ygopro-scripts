--メタルヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，和这张卡存在过的区域相同纵列的对方的卡全部破坏。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「金属被甲弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c32472237.initial_effect(c)
	-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，和这张卡存在过的区域相同纵列的对方的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32472237,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,32472237)
	e1:SetCondition(c32472237.descon)
	e1:SetTarget(c32472237.destg)
	e1:SetOperation(c32472237.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「金属被甲弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c32472237.regop)
	c:RegisterEffect(e2)
end
-- 判断连锁效果是否针对了此卡且该效果为连接怪兽效果
function c32472237.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 计算并设置要破坏的卡组，包括自身和对方同纵列的卡
function c32472237.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	if chk==0 then return c:IsDestructable() and cg:GetCount()>0 end
	cg:AddCard(c)
	-- 设置效果处理时要破坏的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,cg,cg:GetCount(),0,0)
end
-- 执行效果破坏操作，先破坏自身再破坏对方同纵列的卡
function c32472237.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	-- 确认自身存在且被破坏成功，同时对方同纵列有卡可破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 and cg:GetCount()>0 then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 破坏对方同纵列的所有卡
		Duel.Destroy(cg,REASON_EFFECT)
	end
end
-- 判断此卡是否因战斗或效果破坏并进入墓地
function c32472237.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「金属被甲弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(32472237,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,32472238)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c32472237.sptg)
		e1:SetOperation(c32472237.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数，筛选满足条件的「弹丸」怪兽
function c32472237.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(32472237) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件，包括场地空位和卡组存在符合条件的卡
function c32472237.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场地是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组是否存在符合条件的卡
		and Duel.IsExistingMatchingCard(c32472237.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作，从卡组选择符合条件的卡特殊召唤
function c32472237.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场地是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c32472237.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
