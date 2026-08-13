--爆竜剣士イグニスターP
-- 效果：
-- 调整＋调整以外的灵摆怪兽1只以上
-- ①：1回合1次，以场上1只灵摆怪兽或者灵摆区域1张卡为对象才能发动。那张卡破坏，选场上1张卡回到持有者卡组。
-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「龙剑士」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能作为同调素材。
function c18239909.initial_effect(c)
	-- 设定同调召唤手续：调整＋调整以外的灵摆怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_PENDULUM),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，以场上1只灵摆怪兽或者灵摆区域1张卡为对象才能发动。那张卡破坏，选场上1张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18239909,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c18239909.destg)
	e1:SetOperation(c18239909.desop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「龙剑士」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18239909,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c18239909.sptg)
	e2:SetOperation(c18239909.spop)
	c:RegisterEffect(e2)
end
-- desfilter：判断对象是否合法——表侧表示且为灵摆怪兽（包含灵摆区域的灵摆卡），并且场上（除该卡外）存在能返回卡组的卡。
function c18239909.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		-- 检查场上是否存在除候选对象以外能够返回持有者卡组的卡，用于保证①效果处理时能选择回卡组的对象。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- destg：①效果的发动时处理——选择场上1只表侧灵摆怪兽或灵摆区域的卡为对象，并设置破坏和回卡组的操作信息。
function c18239909.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_PZONE) and c18239909.desfilter(chkc) end
	-- 效果发动时（chk==0）检查是否存在满足desfilter条件的可选取对象。
	if chk==0 then return Duel.IsExistingTarget(c18239909.desfilter,tp,LOCATION_MZONE+LOCATION_PZONE,LOCATION_MZONE+LOCATION_PZONE,1,nil) end
	-- 向对方玩家提示已发动了该效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向操作者显示选择要破坏的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作者从满足条件的怪兽/灵摆区域卡中选择1张，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c18239909.desfilter,tp,LOCATION_MZONE+LOCATION_PZONE,LOCATION_MZONE+LOCATION_PZONE,1,1,nil)
	-- 设置操作信息：本次连锁会将对象卡破坏，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次连锁还会从场上选1张卡返回卡组，目标为场上且不取对象（处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_ONFIELD)
end
-- desop：①效果处理——将对象卡破坏，若破坏成功，再从场上选1张卡返回持有者卡组并洗牌。
function c18239909.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果相关（没有被无效或离场等），然后将其破坏；若破坏成功则继续执行后续回卡组处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 向操作者显示选择要返回卡组的卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从场上选择1张能够返回卡组的卡（此时不取对象，由当前玩家在处理时选择）。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 手动展示被选择的卡，并记录其为广义选中对象。
			Duel.HintSelection(g)
			-- 将选中的卡返回持有者卡组，并触发洗牌。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- spfilter：过滤卡组中满足「龙剑士」字段且可以表侧守备表示特殊召唤的怪兽。
function c18239909.spfilter(c,e,tp)
	return c:IsSetCard(0xc7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- sptg：②效果的发动条件——自己主要阶段且主要怪兽区有空位，卡组中存在可特殊召唤的「龙剑士」怪兽。
function c18239909.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己的主要怪兽区域是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：卡组中是否存在符合条件的「龙剑士」怪兽。
		and Duel.IsExistingMatchingCard(c18239909.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示已发动了②效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次连锁会从卡组特殊召唤1只怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- spop：②效果处理——从卡组选1只「龙剑士」怪兽以表侧守备表示特殊召唤，并使其不能作为同调素材。
function c18239909.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示选择要特殊召唤的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「龙剑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c18239909.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的怪兽不能作为同调素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
