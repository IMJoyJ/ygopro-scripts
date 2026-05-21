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
-- 过滤函数：检查卡片是否为表侧表示的「方界」怪兽
function c8837932.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3)
end
-- 发动条件：自己场上存在「方界」怪兽
function c8837932.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「方界」怪兽
	return Duel.IsExistingMatchingCard(c8837932.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检查是否为本回合被破坏送去墓地的怪兽，且能以表侧表示特殊召唤到对方场上并放置方界指示物
function c8837932.spfilter(c,e,tp,tid)
	return c:IsReason(REASON_DESTROY) and c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid
		-- 检查怪兽是否能以表侧表示特殊召唤到对方场上，且能被放置1个方界指示物
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and Duel.IsCanAddCounter(tp,0x1038,1,c)
end
-- 效果选择：以本回合被破坏送去对方墓地的怪兽任意数量为对象
function c8837932.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c8837932.spfilter(chkc,e,tp,tid) end
	-- 获取对方场上主要怪兽区域的空位数
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if chk==0 then return ft>0
		-- 检查对方墓地是否存在至少1只满足特殊召唤和放置指示物条件的怪兽
		and Duel.IsExistingTarget(c8837932.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,tid) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 选择对方墓地中任意数量满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8837932.spfilter,tp,0,LOCATION_GRAVE,1,ft,nil,e,tp,tid)
	-- 设置连锁处理中的操作信息：特殊召唤对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理：将作为对象的怪兽在对方场上特殊召唤，攻击力变成0，并放置方界指示物，使其不能攻击且效果无效化
function c8837932.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上主要怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft<=0 or not c:IsRelateToEffect(e) then return end
	-- 获取仍与此效果关联的对象怪兽
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	local sc=sg:GetFirst()
	while sc do
		-- 尝试将怪兽以表侧表示特殊召唤到对方场上
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
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
	-- 获取本次操作中实际特殊召唤成功的怪兽组
	local og=Duel.GetOperatedGroup()
	local oc=og:GetFirst()
	while oc do
		oc:AddCounter(0x1038,1)
		-- 有方界指示物放置的怪兽不能攻击，效果无效化。
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
-- 条件函数：检查怪兽身上是否存在方界指示物
function c8837932.disable(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
-- 过滤函数：检查卡片是否属于作为对象的怪兽组
function c8837932.dfilter(c,g)
	return g:IsContains(c)
end
-- 效果处理：如果对方发动的怪兽效果是由作为对象的怪兽发动的，则将该效果无效化
function c8837932.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	if re:IsActiveType(TYPE_MONSTER) and rp==1-tp
		-- 检查发动效果的怪兽是否是存在于对方场上的对象怪兽
		and Duel.IsExistingMatchingCard(c8837932.dfilter,tp,0,LOCATION_MZONE,1,nil,g) then
		-- 使该效果无效化
		Duel.NegateEffect(ev)
	end
end
-- 发动条件：作为对象的怪兽全部从场上离开
function c8837932.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	return eg:FilterCount(c8837932.dfilter,nil,g)>0
		-- 检查场上是否已经不存在任何作为对象的怪兽
		and not Duel.IsExistingMatchingCard(c8837932.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,g)
end
-- 效果处理：将这张卡破坏
function c8837932.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将这张卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
