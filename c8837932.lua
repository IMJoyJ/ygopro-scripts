--方界曼荼羅
-- 效果：
-- ①：自己场上有「方界」怪兽存在的场合，以这个回合被破坏送去对方墓地的怪兽任意数量为对象才能把这张卡发动。那些怪兽的攻击力变成0在对方场上特殊召唤，给那些怪兽各放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
-- ②：只要作为对象的怪兽在对方场上存在，对方发动的怪兽的效果无效化。
-- ③：作为对象的怪兽全部从场上离开的场合这张卡破坏。
function c8837932.initial_effect(c)
	-- ①：自己场上有「方界」怪兽存在的场合，以这个回合被破坏送去对方墓地的怪兽任意数量为对象才能把这张卡发动。那些怪兽的攻击力变成0在对方场上特殊召唤，给那些怪兽各放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_END_PHASE)
	e1:SetCondition(c8837932.condition)
	e1:SetTarget(c8837932.target)
	e1:SetOperation(c8837932.activate)
	c:RegisterEffect(e1)
	-- ②：只要作为对象的怪兽在对方场上存在，对方发动的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(c8837932.disop)
	c:RegisterEffect(e2)
	-- ③：作为对象的怪兽全部从场上离开的场合这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c8837932.descon)
	e3:SetOperation(c8837932.desop)
	c:RegisterEffect(e3)
end
c8837932.mentioned_counter={
	[0x1038]=true,
}
-- 发动条件卡片过滤：己方场上表侧表示的「方界」怪兽
function c8837932.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3)
end
-- ①效果发动条件检查：己方场上有表侧表示的「方界」怪兽存在
function c8837932.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否存在表侧表示的「方界」怪兽
	return Duel.IsExistingMatchingCard(c8837932.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤目标过滤条件：本回合被破坏送去对方墓地且可放置方界指示物(0x1038)的怪兽
function c8837932.spfilter(c,e,tp,tid)
	return c:IsReason(REASON_DESTROY) and c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid
		-- 检查怪兽是否能向对方场上特殊召唤且能被放置方界指示物
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and Duel.IsCanAddCounter(tp,0x1038,1,c)
end
-- ①效果发动准备：检查对方场地空位与墓地符合条件的怪兽，选择对象并设置操作信息
function c8837932.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数以校验卡片被破坏的时点
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c8837932.spfilter(chkc,e,tp,tid) end
	-- 获取对方主要怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if chk==0 then return ft>0
		-- 检查对方墓地是否存在本回合被破坏且可特殊召唤的怪兽
		and Duel.IsExistingTarget(c8837932.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,tid) end
	-- 向玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 选择对方墓地任意数量（不超过对方场上空位数）满足条件的怪兽为对象
	local g=Duel.SelectTarget(tp,c8837932.spfilter,tp,0,LOCATION_GRAVE,1,ft,nil,e,tp,tid)
	-- 设置连锁操作信息：将选中的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- ①效果处理：把对象怪兽攻击力变0在对方场上特召，放置方界指示物并封锁攻击与效果
function c8837932.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 重新检查对方主要怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft<=0 or not c:IsRelateToEffect(e) then return end
	-- 获取此卡发动时选择并仍与此效果相关的对象怪兽组
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 当对象数量超出场地空位时，提示玩家选择要在可用空位数内特召的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	local sc=sg:GetFirst()
	while sc do
		-- 尝试将对象怪兽表侧表示特殊召唤到对方场上
		if Duel.SpecialSummonStep(sc,0,tp,1-tp,false,false,POS_FACEUP) then
			c:SetCardTarget(sc)
			-- 那些怪兽的攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
		sc=sg:GetNext()
	end
	-- 完成特殊召唤流程的分步处理
	Duel.SpecialSummonComplete()
	-- 获取本次操作中实际成功特殊召唤的怪兽组
	local og=Duel.GetOperatedGroup()
	local oc=og:GetFirst()
	while oc do
		oc:AddCounter(0x1038,1)
		-- 给那些怪兽各放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetCondition(c8837932.disable)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		oc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE)
		oc:RegisterEffect(e3)
		oc=og:GetNext()
	end
end
-- 方界指示物封锁条件：怪兽身上放置有方界指示物(0x1038)
function c8837932.disable(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
-- 对象怪兽过滤条件：检查卡片是否属于此卡所建立的对象怪兽组
function c8837932.dfilter(c,g)
	return g:IsContains(c)
end
-- ②效果处理：当作为对象的怪兽在对方场上存在时，无效对方发动的怪兽效果
function c8837932.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	if re:IsActiveType(TYPE_MONSTER) and rp==1-tp
		-- 检查对方场上是否依然存在作为对象的怪兽
		and Duel.IsExistingMatchingCard(c8837932.dfilter,tp,0,LOCATION_MZONE,1,nil,g) then
		-- 无效对方发动的该怪兽效果
		Duel.NegateEffect(ev)
	end
end
-- ③效果发动条件检查：作为对象的怪兽全部从场上离开
function c8837932.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	return eg:FilterCount(c8837932.dfilter,nil,g)>0
		-- 判断场上是否已没有任何一只作为对象的怪兽存在
		and not Duel.IsExistingMatchingCard(c8837932.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,g)
end
-- ③效果处理：破坏这张卡
function c8837932.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
