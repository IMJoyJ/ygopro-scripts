--転生炎獣の炎軍
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己的墓地·除外状态的3只炎属性怪兽为对象才能发动。那3只之内的2只回到卡组，剩下的1只特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能攻击。
-- ●持有和原本攻击力不同攻击力的炎属性的仪式·融合·同调·超量·连接怪兽在自己场上存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 注册卡片的效果
function s.initial_effect(c)
	-- 以自己的墓地·除外状态的3只炎属性怪兽为对象才能发动。那3只之内的2只回到卡组，剩下的1只特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能攻击。
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
	-- 持有和原本攻击力不同攻击力的炎属性的仪式·融合·同调·超量·连接怪兽在自己场上存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
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
-- 过滤自己墓地或除外区中可返回卡组的炎属性怪兽
function s.filter1(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx() and c:IsAbleToDeck()
end
-- 过滤可特殊召唤且存在能一同返回卡组之炎属性怪兽的对象卡
function s.filter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查除该怪兽外的墓地或除外区中是否存在至少2张符合返回卡组条件的卡
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,c)
end
-- 选择墓地或除外的怪兽为对象，设置第一个效果发动的目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地或除外区是否存在能特殊召唤且可使另外2张卡返回卡组的卡
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只炎属性怪兽作为特殊召唤的对象
	local g1=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择另外2只炎属性怪兽作为返回卡组的对象
	local g2=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,g1:GetFirst())
	-- 设置返回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,2,0,0)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
-- 第一个效果的处理：将2只怪兽返回卡组，剩下的1只特殊召唤且无效化并无法攻击
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与该连锁关联的作为效果对象的卡
	local g=Duel.GetTargetsRelateToChain()
	if #g~=3 then return end
	-- 获取需要返回卡组之卡片的操作信息
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 获取需要特殊召唤之卡片的操作信息
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	if g1:GetFirst():IsRelateToEffect(e) and g1:GetNext():IsRelateToEffect(e) then
		local tc=g2:GetFirst()
		-- 将选中的2只怪兽送回卡组并洗牌，若成功且特殊召唤的卡仍然关联此效果，则继续处理
		if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
			-- 中断当前效果以使特殊召唤与返回卡组不同时处理
			Duel.BreakEffect()
			-- 将目标怪兽特殊召唤到自己场上
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
			-- 完成特殊召唤的过程
			Duel.SpecialSummonComplete()
		end
	end
end
-- 过滤持有和原本攻击力不同攻击力的炎属性仪式·融合·同调·超量·连接怪兽
function s.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and c:GetAttack()~=c:GetBaseAttack()
end
-- 判断发动条件：自己场上是否存在符合破坏效果条件的炎属性怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在原本攻击力与当前不同的炎属性额外/仪式怪兽
	return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 选择要破坏的场上卡片为对象，设置第二个效果的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断场上是否存在可以成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 第二个效果的处理：破坏作为对象的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的场上卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏作为对象的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
