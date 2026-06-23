--未界域の歓待
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把「未界域」怪兽3种类给对方观看，对方从那之中随机选1只。那1只怪兽在自己场上特殊召唤，剩下的怪兽回到卡组。这个效果特殊召唤的怪兽在结束阶段破坏。
function c10312660.initial_effect(c)
	-- ①：从卡组把「未界域」怪兽3种类给对方观看，对方从那之中随机选1只。那1只怪兽在自己场上特殊召唤，剩下的怪兽回到卡组。这个效果特殊召唤的怪兽在结束阶段破坏。
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
-- 过滤卡组中属于「未界域」系列且可以特殊召唤的怪兽
function c10312660.spfilter(c,e,tp)
	return c:IsSetCard(0x11e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①之效果的发动准备：进行卡名种类数与怪兽区域空位检测，并注册操作信息
function c10312660.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有符合特殊召唤条件的「未界域」怪兽
		local dg=Duel.GetMatchingGroup(c10312660.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 判定卡组中是否包含至少3种不同卡名的「未界域」怪兽，且自己的怪兽区域有空位
		return dg:GetClassCount(Card.GetCode)>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	-- 注册从卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①之效果的效果处理：从卡组选3种「未界域」怪兽给对方观看并由对方随机选1只特召，其余怪兽洗回卡组，并在结束阶段将该特召怪兽破坏
function c10312660.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合特殊召唤条件的「未界域」怪兽
	local g=Duel.GetMatchingGroup(c10312660.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 判定怪兽区域是否已满，或卡组内符合条件的「未界域」怪兽不足3种，若是则停止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or g:GetClassCount(Card.GetCode)<3 then return end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从卡组选择3只卡名不同的「未界域」怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if sg then
		-- 将选出的3只「未界域」怪兽给对方确认
		Duel.ConfirmCards(1-tp,sg)
		local tc=sg:RandomSelect(1-tp,1):GetFirst()
		-- 将对方随机选择的怪兽给己方确认
		Duel.ConfirmCards(tp,tc)
		-- 如果该怪兽以表侧表示成功特殊召唤，则继续进行后续处理
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
			-- 在全局注册用于结束阶段破坏该特殊召唤怪兽的效果
			Duel.RegisterEffect(e1,tp)
		end
		-- 将卡组重新洗牌
		Duel.ShuffleDeck(tp)
	end
end
-- 结束阶段破坏效果的重置与适用条件判定：如果特召的怪兽已离开场上，则重置此效果；否则在结束阶段时适用
function c10312660.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(10312660)~=e:GetLabel() then
		e:Reset()
		return false
	else
		return true
	end
end
-- 结束阶段破坏效果的效果处理：执行怪兽的破坏
function c10312660.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 由于效果将该特殊召唤的怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
