--未界域の歓待
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把「未界域」怪兽3种类给对方观看，对方从那之中随机选1只。那1只怪兽在自己场上特殊召唤，剩下的怪兽回到卡组。这个效果特殊召唤的怪兽在结束阶段破坏。
function c10312660.initial_effect(c)
	-- 这个卡名的卡在 1 回合只能发动 1 张。①：从卡组把「未界域」怪兽 3 种类给对方观看，对方从那之中随机选 1 只。那 1 只怪兽在自己场上特殊召唤，剩下的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,10312660+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c10312660.target)
	e1:SetOperation(c10312660.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数，用于检索卡组中符合条件的「未界域」怪兽。
function c10312660.spfilter(c,e,tp)
	return c:IsSetCard(0x11e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动前的目标检查函数，验证是否满足发动条件。
function c10312660.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足筛选条件的「未界域」怪兽卡片组。
		local dg=Duel.GetMatchingGroup(c10312660.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 判断卡组中是否存在至少 3 种不同卡名的怪兽且场上有空位。
		return dg:GetClassCount(Card.GetCode)>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	-- 设置效果处理信息，告知系统即将特殊召唤 1 只卡组怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行卡片效果的具体操作。
function c10312660.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取卡组中所有满足筛选条件的「未界域」怪兽卡片组。
	local g=Duel.GetMatchingGroup(c10312660.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 再次验证场上是否有空位且卡组中是否有至少 3 种不同卡名的怪兽，否则终止效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or g:GetClassCount(Card.GetCode)<3 then return end
	-- 向玩家显示选择提示信息，提示将要确认卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 让玩家从符合条件的卡片组中选择 3 张卡名不同的怪兽。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if sg then
		-- 将选中的 3 只怪兽给对方玩家观看。
		Duel.ConfirmCards(1-tp,sg)
		local tc=sg:RandomSelect(1-tp,1):GetFirst()
		-- 将对方随机选出的 1 只怪兽给自己玩家观看。
		Duel.ConfirmCards(tp,tc)
		-- 将选中的 1 只怪兽在自己场上特殊召唤。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local fid=tc:GetFieldID()
			tc:RegisterFlagEffect(10312660,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 这个效果特殊召唤的怪兽在结束阶段破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(c10312660.descon)
			e1:SetOperation(c10312660.desop)
			-- 注册结束阶段破坏怪兽的永续效果。
			Duel.RegisterEffect(e1,tp)
		end
		-- 将卡组洗切，重置卡组顺序。
		Duel.ShuffleDeck(tp)
	end
end
-- 破坏效果的条件检查函数，验证怪兽是否仍在场且标记有效。
function c10312660.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(10312660)~=e:GetLabel() then
		e:Reset()
		return false
	else
		return true
	end
end
-- 破坏效果的处理函数，执行怪兽破坏操作。
function c10312660.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因破坏该怪兽。
	Duel.Destroy(tc,REASON_EFFECT)
end
