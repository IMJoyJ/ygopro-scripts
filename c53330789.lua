--VS トリニティ・バースト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「征服斗魂」怪兽为对象才能发动。原本属性和那只怪兽不同的最多2只「征服斗魂」怪兽从手卡效果无效特殊召唤（同名卡最多1张）。那之后，可以让位于作为对象的自己怪兽以及这个效果特殊召唤的怪兽的正对面的对方场上的卡全部回到持有者手卡。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
function c53330789.initial_effect(c)
	-- 创建效果，设置为发动时点，具有取对象属性，发动次数限制为1次，设置提示时点为怪兽登场和结束阶段，设置目标函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53330789+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c53330789.target)
	e1:SetOperation(c53330789.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中满足条件的「征服斗魂」怪兽：必须是「征服斗魂」卡组、可以特殊召唤、原本属性与目标怪兽不同
function c53330789.spfilter(c,e,tp,attr)
	return c:IsSetCard(0x195) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetOriginalAttribute()~=attr
end
-- 过滤自己场上满足条件的「征服斗魂」怪兽：必须是表侧表示、是「征服斗魂」卡组、可以回到手牌，并且存在满足spfilter条件的怪兽
function c53330789.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x195) and c:IsAbleToHand()
		-- 检查是否存在满足spfilter条件的怪兽，用于确认是否能发动效果
		and Duel.IsExistingMatchingCard(c53330789.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetOriginalAttribute())
end
-- 设置目标函数，当chkc不为空时返回是否为满足filter条件的目标；当chk==0时检查是否有满足filter条件的怪兽作为对象
function c53330789.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53330789.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 检查自己场上是否存在满足filter条件的怪兽
		and Duel.IsExistingTarget(c53330789.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足filter条件的1只怪兽作为对象
	Duel.SelectTarget(tp,c53330789.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤最多1张手卡中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理函数开始，获取效果处理器和目标怪兽，检查目标是否为表侧表示且有效
function c53330789.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local attr=tc:GetOriginalAttribute()
		-- 获取自己场上可用的怪兽区数量
		local max=Duel.GetMZoneCount(tp)
		if max>2 then max=2 end
		if max<1 then return end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then max=1 end
		-- 获取满足spfilter条件的手卡怪兽组
		local g=Duel.GetMatchingGroup(c53330789.spfilter,tp,LOCATION_HAND,0,nil,e,tp,attr)
		if #g==0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从满足条件的怪兽中选择最多max张，确保卡名不重复
		local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,max)
		local rg=tc:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
		local fid=c:GetFieldID()
		local sg=Group.CreateGroup()
		-- 遍历选中的怪兽进行处理
		for sc in aux.Next(tg) do
			-- 尝试特殊召唤该怪兽
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				-- 给特殊召唤的怪兽添加效果：无效化其效果
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 给特殊召唤的怪兽添加效果：无效化其效果（直到回合结束）
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
				sc:RegisterFlagEffect(53330789,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				rg:Merge(sc:GetColumnGroup():Filter(Card.IsControler,nil,1-tp))
				sg:AddCard(sc)
			end
		end
		if #sg>0 then
			sg:KeepAlive()
			-- 注册一个在结束阶段触发的效果，用于将特殊召唤的怪兽送回手牌
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(sg)
			e1:SetCondition(c53330789.thcon)
			e1:SetOperation(c53330789.thop)
			-- 注册该结束阶段效果到玩家
			Duel.RegisterEffect(e1,tp)
		end
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
		-- 如果存在对方场上的卡需要送回手牌，则询问玩家是否发动此效果
		if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(53330789,1)) then  --"是否把对方的卡回到手卡？"
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将对方场上的卡全部送回手牌
			Duel.SendtoHand(rg,nil,REASON_EFFECT)
		end
	end
end
-- 用于判断怪兽是否为本次效果特殊召唤的怪兽
function c53330789.thfilter(c,fid)
	return c:GetFlagEffectLabel(53330789)==fid
end
-- 结束阶段时点触发的条件函数，检查是否有满足thfilter条件的怪兽
function c53330789.thcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c53330789.thfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段时点触发的操作函数，将符合条件的怪兽送回手牌
function c53330789.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c53330789.thfilter,nil,e:GetLabel())
	-- 将符合条件的怪兽送回手牌
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
end
