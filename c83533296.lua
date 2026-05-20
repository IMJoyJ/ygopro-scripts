--転生炎獣の炎軍
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己的墓地·除外状态的3只炎属性怪兽为对象才能发动。那3只之内的2只回到卡组，剩下的1只特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能攻击。
-- ●持有和原本攻击力不同攻击力的炎属性的仪式·融合·同调·超量·连接怪兽在自己场上存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 注册卡片发动时的两个可选效果（效果①的两个分支）
function s.initial_effect(c)
	-- ●以自己的墓地·除外状态的3只炎属性怪兽为对象才能发动。那3只之内的2只回到卡组，剩下的1只特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收除外的怪兽"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ●持有和原本攻击力不同攻击力的炎属性的仪式·融合·同调·超量·连接怪兽在自己场上存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"场上卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：墓地或除外状态的、可以回到卡组的炎属性怪兽
function s.filter1(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx() and c:IsAbleToDeck()
end
-- 过滤条件：可以特殊召唤的炎属性怪兽，且除自身外还存在至少2只满足回到卡组条件的炎属性怪兽
function s.filter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查除自身（作为特召对象）以外，墓地或除外状态中是否存在至少2只可以回到卡组的炎属性怪兽
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,c)
end
-- 效果①分支1（特召/回收）的发动准备与对象选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自身场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地或除外状态是否存在至少1只满足特殊召唤条件（且伴随另外2只可回收卡）的炎属性怪兽
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只墓地或除外状态的炎属性怪兽作为特殊召唤的对象
	local g1=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择另外2只墓地或除外状态的炎属性怪兽作为返回卡组的对象
	local g2=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,g1:GetFirst())
	-- 设置连锁信息：包含2张卡回到卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,2,0,0)
	-- 设置连锁信息：包含1张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
-- 效果①分支1（特召/回收）的效果处理：将2只对象怪兽送回卡组，并特殊召唤剩下的1只，使其效果无效且不能攻击
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果有关联的对象卡片
	local g=Duel.GetTargetsRelateToChain()
	if #g~=3 then return end
	-- 获取预设的需要回到卡组的卡片组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 获取预设的需要特殊召唤的卡片组
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	if g1:GetFirst():IsRelateToEffect(e) and g1:GetNext():IsRelateToEffect(e) then
		local tc=g2:GetFirst()
		-- 将2只对象怪兽送回卡组并洗牌，若成功且特召对象仍与效果有关联，则继续处理
		if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) and tc:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的特殊召唤不与回到卡组视为同时处理
			Duel.BreakEffect()
			-- 将剩下的1只对象怪兽以表侧表示特殊召唤（分步处理）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽在这个回合效果无效化
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_ATTACK)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			-- 完成特殊召唤的后续处理
			Duel.SpecialSummonComplete()
		end
	end
end
-- 过滤条件：场上表侧表示的、当前攻击力与原本攻击力不同的炎属性仪式·融合·同调·超量·连接怪兽
function s.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and c:GetAttack()~=c:GetBaseAttack()
end
-- 效果①分支2（破坏场上卡）的发动条件判定
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足条件的炎属性额外/仪式怪兽
	return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①分支2（破坏场上卡）的发动准备与对象选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为对象的卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息：包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①分支2（破坏场上卡）的效果处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为破坏对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
