--K9－EW特殊解除実験
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只「K9」怪兽特殊召唤。那之后，可以把1只「K9」超量怪兽在这个效果特殊召唤的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果从额外卡组特殊召唤的怪兽在下个回合的结束阶段破坏。
-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己墓地1张「K9」速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡的效果，包括①②两个效果
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只「K9」怪兽特殊召唤。那之后，可以把1只「K9」超量怪兽在这个效果特殊召唤的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果从额外卡组特殊召唤的怪兽在下个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己墓地1张「K9」速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	-- 支付将此卡除外的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「K9」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或墓地是否有「K9」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤满足条件的「K9」超量怪兽
function s.xyzfilter(c,e,tp,mc)
	return c:IsSetCard(0x1cb) and mc:IsCanBeXyzMaterial(c)
		-- 判断超量怪兽是否满足特殊召唤条件
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 判断是否满足①效果的发动条件
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要特殊召唤的卡
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 选择满足条件的「K9」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 特殊召唤选中的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 调整场上状态
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 判断是否满足超量召唤条件
		Duel.AdjustAll()
		-- 询问是否进行超量召唤
		if aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc)
			-- 中断当前效果处理
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否超量召唤？"
			-- 提示选择要特殊召唤的超量怪兽
			Duel.BreakEffect()
			-- 选择满足条件的「K9」超量怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 将选中的怪兽叠放至特殊召唤的怪兽上
			local sg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
			local sc=sg:GetFirst()
			if sc then
				local mg=tc:GetOverlayGroup()
				if mg:GetCount()~=0 then
					-- 将选中的怪兽叠放至特殊召唤的怪兽上
					Duel.Overlay(sc,mg)
				end
				sc:SetMaterial(Group.FromCards(tc))
				-- 设置超量怪兽的素材
				Duel.Overlay(sc,Group.FromCards(tc))
				-- 特殊召唤超量怪兽
				Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
				sc:CompleteProcedure()
				sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
				-- 为超量怪兽注册在下个回合结束时破坏的效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetCondition(s.descon)
				e1:SetOperation(s.desop)
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				e1:SetCountLimit(1)
				-- 记录当前回合数
				e1:SetLabel(Duel.GetTurnCount())
				e1:SetLabelObject(sc)
				-- 注册破坏效果
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 判断是否满足破坏条件
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断是否为下个回合且怪兽仍存在
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(id)>0
end
-- 执行破坏操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 破坏怪兽
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 过滤满足条件的「K9」速攻魔法卡
function s.setfilter(c)
	return c:IsSetCard(0x1cb) and c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- 判断是否满足②效果的发动条件
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 判断是否满足②效果的发动条件
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.setfilter(chkc) end
	-- 判断墓地是否有满足条件的速攻魔法卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的速攻魔法卡
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理时要盖放的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行盖放操作
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标卡盖放
		Duel.SSet(tp,tc)
	end
end
