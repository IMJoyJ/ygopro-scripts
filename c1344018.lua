--時空のペンデュラムグラフ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，对方不能把自己场上的魔法师族怪兽作为陷阱卡的效果的对象。
-- ②：以自己的怪兽区域·灵摆区域1张「魔术师」灵摆怪兽卡和对方场上1张卡为对象才能发动。那些卡破坏。没能因这个效果把2张卡破坏的场合，可以把场上1张卡送去墓地。
function c1344018.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，对方不能把自己场上的魔法师族怪兽作为陷阱卡的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 将保护目标限定为己方场上的魔法师族怪兽，即只有魔法师族怪兽才能受到该效果的保护。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e2:SetValue(c1344018.evalue)
	c:RegisterEffect(e2)
	-- ②：以自己的怪兽区域·灵摆区域1张「魔术师」灵摆怪兽卡和对方场上1张卡为对象才能发动。那些卡破坏。没能因这个效果把2张卡破坏的场合，可以把场上1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1344018,0))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,1344018)
	e3:SetTarget(c1344018.destg)
	e3:SetOperation(c1344018.desop)
	c:RegisterEffect(e3)
end
-- 该值函数用于判定当前发动连锁的效果是否为对方发动的陷阱卡效果，即只有对方发动的陷阱卡效果才不能以己方魔法师族怪兽为对象。
function c1344018.evalue(e,re,rp)
	return re:IsActiveType(TYPE_TRAP) and rp==1-e:GetHandlerPlayer()
end
-- 对象筛选条件：表侧表示、属于「魔术师」系列、且为灵摆怪兽，对应己方怪兽区域或灵摆区域中的「魔术师」灵摆怪兽。
function c1344018.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end
-- 效果发动目标的合法性检测与选取：检查是否存在可选择的己方「魔术师」灵摆怪兽和对方场上的卡，若存在则分别选择作为对象。
function c1344018.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查己方的怪兽区域·灵摆区域是否存在至少1张满足条件的「魔术师」灵摆怪兽卡，作为效果发动的必要前提。
	if chk==0 then return Duel.IsExistingTarget(c1344018.desfilter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张可以作为效果对象的卡，保证可以选取对方场上1张卡为对象。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向发动者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动者从自己的怪兽区域·灵摆区域选择1张符合条件的「魔术师」灵摆怪兽卡作为效果对象。
	local g1=Duel.SelectTarget(tp,c1344018.desfilter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,1,nil)
	-- 再次显示“请选择要破坏的卡”的选择提示，用于选取对方场上的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动者选择对方场上1张卡作为效果对象，无卡名限制。
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 将已选中的2张卡登记为本连锁的处理信息，分类为破坏，数量为2，供后续处理与检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ②效果的实际处理：破坏取对象的两张卡；若未能破坏2张，则追加将场上1张卡送去墓地的处理。
function c1344018.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡，并从中筛选出仍与效果存在关联的卡（没有被无效、离场等导致联系重置）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因破坏筛选出的对象卡；若实际破坏数量不等于2，则进入后续追加处理。
	if Duel.Destroy(g,REASON_EFFECT)~=2 then
		-- 取得场上（双方怪兽区域与魔法·陷阱区域）的所有卡，作为追加要求送去墓地的候选范围。
		local g2=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		-- 若场上存在可选择的卡，且发动者选择“是”，则执行追加处理，否则结束。
		if g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1344018,1)) then  --"是否选场上1张卡送去墓地？"
			-- 中断当前效果，使追加的送墓处理不被视为与破坏处理同时进行，以保持连锁时点正确。
			Duel.BreakEffect()
			-- 提示发动者选择要送去墓地的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sg=g2:Select(tp,1,1,nil)
			-- 为最终选中的卡播放被选择动画，并记录其成为这次效果的对象。
			Duel.HintSelection(sg)
			-- 将选中的卡以效果原因送去墓地。
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
