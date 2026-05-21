--漆黒の薔薇の開華
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把最多有双方的场地区域的卡以及墓地的场地魔法卡数量的「蔷薇衍生物」（植物族·暗·2星·攻/守800）在自己·对方场上守备表示特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己场上1只「黑蔷薇龙」或者植物族怪兽为对象才能发动。那只怪兽除外，这张卡回到卡组最下面。这个效果除外的怪兽在下次的准备阶段回到场上。
function c99092624.initial_effect(c)
	-- 记录这张卡的效果中记载了「黑蔷薇龙」的卡名。
	aux.AddCodeList(c,73580471)
	-- ①：把最多有双方的场地区域的卡以及墓地的场地魔法卡数量的「蔷薇衍生物」（植物族·暗·2星·攻/守800）在自己·对方场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99092624.target)
	e1:SetOperation(c99092624.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只「黑蔷薇龙」或者植物族怪兽为对象才能发动。那只怪兽除外，这张卡回到卡组最下面。这个效果除外的怪兽在下次的准备阶段回到场上。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,99092624)
	e2:SetTarget(c99092624.tdtg)
	e2:SetOperation(c99092624.tdop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动准备与合法性检测（收集场地卡数量并确认双方场上是否有空位可进行衍生物的特殊召唤）。
function c99092624.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算双方场地区域的卡以及双方墓地的场地魔法卡的总数量。
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)+Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_FIELD)
		if ct==0 then return false end
		for p=0,1 do
			-- 检查玩家p的怪兽区域是否有空位，且是否能将「蔷薇衍生物」在玩家p的场上守备表示特殊召唤。
			if Duel.GetLocationCount(p,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,71645243,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,p) then return true end
		end
		return false
	end
	-- 设置特殊召唤的操作信息（预计特殊召唤1只以上的怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	-- 设置衍生物产生的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- ①号效果的处理（在自己或对方场上特殊召唤对应数量的「蔷薇衍生物」）。
function c99092624.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新计算双方场地区域的卡以及双方墓地的场地魔法卡的总数量，作为可特招衍生物的最大数量。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)+Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_FIELD)
	if ct==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	repeat
		-- 检查自己场上是否还有空位且可以特殊召唤「蔷薇衍生物」。
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,71645243,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,tp)
		-- 检查对方场上是否还有空位且可以特殊召唤「蔷薇衍生物」。
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,71645243,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp)
		if not (b1 or b2) then break end
		local op=0
		if b1 and b2 then
			-- 当双方场上都可以特招时，让发动效果的玩家选择在自己场上还是对方场上特殊召唤。
			op=Duel.SelectOption(tp,aux.Stringid(99092624,1),aux.Stringid(99092624,2))  --"在自己场上特殊召唤/在对方场上特殊召唤"
		elseif b1 then
			-- 当只有自己场上可以特招时，强制选择在自己场上特殊召唤。
			op=Duel.SelectOption(tp,aux.Stringid(99092624,1))  --"在自己场上特殊召唤"
		else
			-- 当只有对方场上可以特招时，强制选择在对方场上特殊召唤并修正选项索引。
			op=Duel.SelectOption(tp,aux.Stringid(99092624,2))+1  --"在对方场上特殊召唤"
		end
		local p=tp
		if op>0 then p=1-tp end
		-- 创建「蔷薇衍生物」的卡片数据。
		local token=Duel.CreateToken(tp,99092625)
		-- 将衍生物以表侧守备表示特殊召唤到选定玩家p的场上（分步处理）。
		Duel.SpecialSummonStep(token,0,tp,p,false,false,POS_FACEUP_DEFENSE)
		ct=ct-1
	-- 循环直到达到最大特招数量，或者玩家选择不再继续特殊召唤。
	until ct==0 or not Duel.SelectYesNo(tp,aux.Stringid(99092624,0))  --"是否继续特殊召唤？"
	-- 完成所有分步特殊召唤的处理。
	Duel.SpecialSummonComplete()
end
-- 过滤自己场上表侧表示、可以除外，且是「黑蔷薇龙」或植物族的怪兽。
function c99092624.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
		and (c:IsCode(73580471) or c:IsRace(RACE_PLANT))
end
-- ②号效果的发动准备与对象选择（确认自身能回到卡组最下方，且自己场上有符合条件的怪兽）。
function c99092624.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c99092624.rmfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToDeck()
		-- 检查自己场上是否存在可以作为此效果对象的「黑蔷薇龙」或植物族怪兽。
		and Duel.IsExistingTarget(c99092624.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只「黑蔷薇龙」或者植物族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c99092624.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置除外的操作信息（对象怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置回到卡组的操作信息（墓地的这张卡）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②号效果的处理（将对象怪兽暂时除外，并将此卡回到卡组最下面，同时注册下次准备阶段将怪兽返回场上的效果）。
function c99092624.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用效果，则将其因效果暂时除外。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
		-- 这个效果除外的怪兽在下次的准备阶段回到场上。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		-- 检查当前是否已经是准备阶段（用于处理在准备阶段发动此效果时，怪兽应在“下次”即下个回合的准备阶段返回）。
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			-- 记录当前回合数，以确保怪兽不会在当前回合的准备阶段立即返回。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c99092624.retcon)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		end
		e1:SetOperation(c99092624.retop)
		-- 注册用于在准备阶段将怪兽返回场上的全局时点效果。
		Duel.RegisterEffect(e1,tp)
		if c:IsRelateToEffect(e) then
			-- 将墓地的这张卡回到持有者卡组最下面。
			Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- 检查是否已到下一个回合（防止在发动效果的当个准备阶段内直接返回）。
function c99092624.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合数不等于发动效果时的回合数。
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 执行将暂时除外的怪兽返回场上的操作。
function c99092624.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将被暂时除外的对象怪兽返回到场上。
	Duel.ReturnToField(tc)
end
