--生存境界
-- 效果：
-- ①：场上的通常怪兽全部破坏，把最多有破坏数量的4星以下的恐龙族怪兽从卡组往自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
-- ②：把墓地的这张卡除外，以自己场上1只恐龙族怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
function c44612603.initial_effect(c)
	-- 效果①：场上的通常怪兽全部破坏，把最多有破坏数量的4星以下的恐龙族怪兽从卡组往自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44612603,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c44612603.target)
	e1:SetOperation(c44612603.activate)
	c:RegisterEffect(e1)
	-- 效果②：把墓地的这张卡除外，以自己场上1只恐龙族怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44612603,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44612603.destg)
	e2:SetOperation(c44612603.desop)
	c:RegisterEffect(e2)
end
-- 通常怪兽过滤器，用于检索场上的通常怪兽
function c44612603.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 特殊召唤怪兽过滤器，用于检索4星以下的恐龙族怪兽
function c44612603.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件判断，检查场上是否存在通常怪兽以及手牌或卡组中是否存在符合条件的恐龙族怪兽
function c44612603.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44612603.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查手牌或卡组中是否存在符合条件的恐龙族怪兽
		and Duel.IsExistingMatchingCard(c44612603.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 检索场上的通常怪兽
	local g=Duel.GetMatchingGroup(c44612603.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息，将要破坏的通常怪兽数量记录到操作信息中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息，将要特殊召唤的恐龙族怪兽数量记录到操作信息中
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，先破坏场上通常怪兽，再从卡组特殊召唤符合条件的恐龙族怪兽
function c44612603.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上的通常怪兽
	local g=Duel.GetMatchingGroup(c44612603.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将场上通常怪兽全部破坏
	local n=Duel.Destroy(g,REASON_EFFECT)
	if n~=0 then
		-- 检索卡组中符合条件的恐龙族怪兽
		local tg=Duel.GetMatchingGroup(c44612603.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 获取玩家场上可用的怪兽区域数量
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ct<0 then return end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
		ct=math.min(ct,n)
		if ct>0 and tg:GetCount()>0 then
			-- 中断当前效果处理，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的恐龙族怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=tg:Select(tp,1,ct,nil)
			-- 将选择的恐龙族怪兽特殊召唤到场上
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
				-- 获取实际特殊召唤的怪兽组
				local sg2=Duel.GetOperatedGroup()
				local fid=e:GetHandler():GetFieldID()
				local tc=sg2:GetFirst()
				while tc do
					tc:RegisterFlagEffect(44612603,RESET_EVENT+RESETS_STANDARD,0,0,fid)
					tc=sg2:GetNext()
				end
				sg2:KeepAlive()
				-- 创建一个在结束阶段时破坏特殊召唤怪兽的效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetCountLimit(1)
				e1:SetLabel(fid)
				e1:SetLabelObject(sg2)
				e1:SetCondition(c44612603.descon2)
				e1:SetOperation(c44612603.desop2)
				-- 将结束阶段破坏效果注册到场上
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 特殊召唤怪兽的过滤器，用于判断怪兽是否为本次特殊召唤的怪兽
function c44612603.desfilter2(c,fid)
	return c:GetFlagEffectLabel(44612603)==fid
end
-- 结束阶段破坏效果的触发条件，判断特殊召唤的怪兽是否还存在
function c44612603.descon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c44612603.desfilter2,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的处理函数，将符合条件的怪兽破坏
function c44612603.desop2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c44612603.desfilter2,nil,e:GetLabel())
	-- 将符合条件的怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
-- 恐龙族怪兽过滤器，用于检索场上的恐龙族怪兽
function c44612603.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 效果②的发动条件判断，检查自己场上是否存在恐龙族怪兽以及对方场上是否存在可破坏的卡
function c44612603.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在恐龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c44612603.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可破坏的卡
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的恐龙族怪兽作为对象
	local g1=Duel.SelectTarget(tp,c44612603.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的卡作为对象
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，将要破坏的卡数量记录到操作信息中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果②的处理函数，将选择的对象卡破坏
function c44612603.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的对象卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将对象卡破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
