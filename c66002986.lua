--SR/CWW
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的风属性同调怪兽的种族种类数量的对方场上的卡为对象才能发动。那些卡破坏。
-- ②：对方把怪兽特殊召唤的场合，把墓地的这张卡除外，以自己场上1只风属性同调怪兽为对象才能发动。那只怪兽除外。那之后，这个效果除外的怪兽回到场上。
local s,id,o=GetID()
-- 定义卡片效果初始化函数，注册①和②效果
function s.initial_effect(c)
	-- ①：以最多有自己场上的风属性同调怪兽的种族种类数量的对方场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽特殊召唤的场合，把墓地的这张卡除外，以自己场上1只风属性同调怪兽为对象才能发动。那只怪兽除外。那之后，这个效果除外的怪兽回到场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外并回到场上"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.rmcon)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的风属性同调怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO)
end
-- ①效果的发动准备，检查并选择对方场上的卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查自己场上是否存在风属性同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可作为对象的目标卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取自己场上所有表侧表示的风属性同调怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local gc=g:GetClassCount(Card.GetRace)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多等同于自己场上风属性同调怪兽种族种类数量的对方场上的卡作为对象
	local sg=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,gc,nil)
	-- 设置效果处理信息，包含破坏操作和被选择的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果的处理函数，破坏作为对象的目标卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 破坏这些对象卡
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- ②效果的发动条件：对方特殊召唤怪兽的场合
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 过滤条件：自己场上表侧表示、可以被除外的风属性同调怪兽
function s.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsAbleToRemove()
end
-- ②效果的发动准备，选择自己场上1只风属性同调怪兽作为除外对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
	-- 检查自己场上是否存在可作为除外对象的风属性同调怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只风属性同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，包含除外操作和被选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的处理函数，将选择的怪兽暂时除外，之后使其回到场上
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并将其暂时除外
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0
		and not tc:IsReason(REASON_REDIRECT) and tc:IsLocation(LOCATION_REMOVED) then
		-- 中断效果处理，使后续的回到场上处理不同时进行
		Duel.BreakEffect()
		-- 将被该效果除外的怪兽返回到场上
		Duel.ReturnToField(tc)
	end
end
