--VS トリニティ・バースト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「征服斗魂」怪兽为对象才能发动。原本属性和那只怪兽不同的最多2只「征服斗魂」怪兽从手卡效果无效特殊召唤（同名卡最多1张）。那之后，可以让位于作为对象的自己怪兽以及这个效果特殊召唤的怪兽的正对面的对方场上的卡全部回到持有者手卡。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
function c53330789.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「征服斗魂」怪兽为对象才能发动。原本属性和那只怪兽不同的最多2只「征服斗魂」怪兽从手卡效果无效特殊召唤（同名卡最多1张）。那之后，可以让位于作为对象的自己怪兽以及这个效果特殊召唤的怪兽的正对面的对方场上的卡全部回到持有者手卡。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
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
-- 筛选手牌中属于「征服斗魂」、可被效果特殊召唤且原本属性与对象怪兽不同的怪兽，作为本次可特殊召唤的候选。
function c53330789.spfilter(c,e,tp,attr)
	return c:IsSetCard(0x195) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetOriginalAttribute()~=attr
end
-- 判定场上是否存在可作为对象的表侧表示「征服斗魂」怪兽（且该怪兽能被送去手卡），并且手牌中存在满足特殊召唤条件的候选怪兽。
function c53330789.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x195) and c:IsAbleToHand()
		-- 检查手牌中是否存在至少1只原本属性与对象怪兽不同、且可被效果特殊召唤的「征服斗魂」怪兽。
		and Duel.IsExistingMatchingCard(c53330789.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetOriginalAttribute())
end
-- 设置效果发动条件：自己场上有可成为对象的「征服斗魂」怪兽、有可用怪兽区且手牌有符合条件的「征服斗魂」怪兽；满足后选择对象。
function c53330789.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53330789.filter(chkc,e,tp) end
	-- 发动时确认自己场上存在可用的怪兽区，以保证后续特殊召唤有空格。
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 确认自己场上存在至少1只满足条件的「征服斗魂」怪兽可被选为对象。
		and Duel.IsExistingTarget(c53330789.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向操作者显示“请选择效果的对象”的提示，引导其选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让操作者从自己场上选择1只符合条件的「征服斗魂」怪兽，并将其登记为本连锁的对象。
	Duel.SelectTarget(tp,c53330789.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：本效果包含特殊召唤，预计从手牌特殊召唤1只怪兽，用于时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：根据对象怪兽的原本属性，从手牌选出最多2只卡名互不相同且原本属性不同的「征服斗魂」怪兽进行效果无效特殊召唤；之后可选择将对象怪兽及特召怪兽正对面的对方场上的卡返回持有者手卡；并为这些特召怪兽设置结束阶段返回手牌的持续效果。
function c53330789.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local attr=tc:GetOriginalAttribute()
		-- 计算自己场上当前可用的怪兽区数量，用以限制最多特殊召唤2只。
		local max=Duel.GetMZoneCount(tp)
		if max>2 then max=2 end
		if max<1 then return end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then max=1 end
		-- 获取手牌中所有原本属性与对象不同且可特殊召唤的「征服斗魂」怪兽。
		local g=Duel.GetMatchingGroup(c53330789.spfilter,tp,LOCATION_HAND,0,nil,e,tp,attr)
		if #g==0 then return end
		-- 显示“请选择要特殊召唤的卡”的提示，让玩家选择要特召的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从候选中选择1到max张卡名互不相同的「征服斗魂」怪兽（同名卡最多1张），作为本次特殊召唤的对象。
		local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,max)
		local rg=tc:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
		local fid=c:GetFieldID()
		local sg=Group.CreateGroup()
		-- 遍历玩家选择的每一只怪兽，依次进行特殊召唤处理。
		for sc in aux.Next(tg) do
			-- 以正面表示将当前选择怪兽特殊召唤到自己的怪兽区；若成功则继续执行后续的无效化与记录处理。
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				-- 效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 效果无效
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
			-- 那之后，可以让位于作为对象的自己怪兽以及这个效果特殊召唤的怪兽的正对面的对方场上的卡全部回到持有者手卡。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(sg)
			e1:SetCondition(c53330789.thcon)
			e1:SetOperation(c53330789.thop)
			-- 将结束阶段使特召怪兽返回手牌的持续效果注册到当前决斗中，使其在结束阶段触发。
			Duel.RegisterEffect(e1,tp)
		end
		-- 完成所有SpecialSummonStep的特殊召唤处理，使怪兽正式上场。
		Duel.SpecialSummonComplete()
		-- 若存在位于对象怪兽或特召怪兽正对面的对方场上的卡，则询问操作者是否将这些卡返回持有者手卡。
		if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(53330789,1)) then  --"是否把对方的卡回到手卡？"
			-- 中断当前效果，使后续的回手处理与特殊召唤处理不在同一时点进行，避免错过时点。
			Duel.BreakEffect()
			-- 将选中的对方场上的卡全部返回持有者手卡。
			Duel.SendtoHand(rg,nil,REASON_EFFECT)
		end
	end
end
-- 判断怪兽是否带有本次特殊召唤时分配的编号标志，用于锁定结束阶段需要返回手牌的怪兽。
function c53330789.thfilter(c,fid)
	return c:GetFlagEffectLabel(53330789)==fid
end
-- 结束阶段的触发条件：若仍有带对应标志的特召怪兽存在于场上，则执行回手；否则清理记录并重置效果。
function c53330789.thcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c53330789.thfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段效果处理：过滤出带对应标志的特召怪兽，将其返回持有者手卡。
function c53330789.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c53330789.thfilter,nil,e:GetLabel())
	-- 实际执行将指定怪兽返回持有者手卡的操作。
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
end
