--グランドレミコード・クーリア
-- 效果：
-- 包含灵摆怪兽的怪兽2只以上
-- ①：这张卡的攻击力上升自己的额外卡组的表侧的灵摆怪兽数量×100。
-- ②：这张卡所连接区发动的灵摆怪兽的效果不会被无效化。
-- ③：1回合1次，对方把效果发动时才能发动。自己的灵摆区域1张灵摆刻度是奇数的「七音服」卡在作为这张卡所连接区的自己场上特殊召唤，那个发动无效。那之后，可以从卡组把1只灵摆刻度是偶数的「七音服」灵摆怪兽表侧加入额外卡组。
function c84521924.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要2到3只怪兽作为素材，且素材中必须包含灵摆怪兽。
	aux.AddLinkProcedure(c,nil,2,3,c84521924.lcheck)
	-- ①：这张卡的攻击力上升自己的额外卡组的表侧的灵摆怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c84521924.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区发动的灵摆怪兽的效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c84521924.effectfilter)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把效果发动时才能发动。自己的灵摆区域1张灵摆刻度是奇数的「七音服」卡在作为这张卡所连接区的自己场上特殊召唤，那个发动无效。那之后，可以从卡组把1只灵摆刻度是偶数的「七音服」灵摆怪兽表侧加入额外卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(84521924,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c84521924.spcon)
	e4:SetTarget(c84521924.sptg)
	e4:SetOperation(c84521924.spop)
	c:RegisterEffect(e4)
end
-- 用于检查连接素材中是否包含至少1只灵摆怪兽的过滤函数。
function c84521924.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_PENDULUM)
end
-- 计算攻击力上升数值的函数，返回自己额外卡组表侧表示的灵摆怪兽数量乘以100。
function c84521924.atkval(e,c)
	-- 获取自己额外卡组中表侧表示的灵摆怪兽数量。
	local ct=Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsType),e:GetHandlerPlayer(),LOCATION_EXTRA,0,nil,TYPE_PENDULUM)
	return ct*100
end
-- 过滤不会被无效化的效果，判断发动的效果是否为自己场上此卡所连接区的灵摆怪兽所发动。
function c84521924.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local lg=e:GetHandler():GetLinkedGroup()
	-- 获取指定连锁的效果、发动位置、区域序号以及发动玩家等连锁信息。
	local te,loc,seq,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return te:IsActiveType(TYPE_PENDULUM) and bit.band(loc,LOCATION_MZONE)~=0 and bit.extract(e:GetHandler():GetLinkedZone(),seq)~=0 and p==tp
end
-- 效果③的发动条件：此卡没有因战斗被破坏，且对方发动的效果可以被无效。
function c84521924.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查并返回自身是否未被战斗破坏、当前连锁的效果是否可以被无效、以及是否为对方玩家发动的效果。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- 过滤灵摆区域中刻度为奇数的「七音服」卡，且该卡可以特殊召唤到此卡所连接的区域。
function c84521924.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x162) and c:GetCurrentScale()%2==1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果③的发动准备与合法性检查，设置特殊召唤和无效发动的操作信息。
function c84521924.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)
		-- 检查自己的灵摆区域是否存在至少1张可以特殊召唤到此卡连接区的奇数刻度「七音服」卡。
		return Duel.IsExistingMatchingCard(c84521924.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp,zone)
	end
	-- 设置特殊召唤的操作信息，表示将从灵摆区特殊召唤1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
	-- 设置无效发动的操作信息，表示将无效对方发动的效果。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 过滤卡组中刻度为偶数的「七音服」灵摆怪兽。
function c84521924.tefilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:GetCurrentScale()%2==0
end
-- 效果③的效果处理：特殊召唤灵摆区的奇数刻度「七音服」卡，无效对方效果，并可选择将卡组的偶数刻度「七音服」灵摆怪兽表侧加入额外卡组。
function c84521924.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 获取自己灵摆区域中所有满足特殊召唤条件的奇数刻度「七音服」卡。
	local g=Duel.GetMatchingGroup(c84521924.spfilter,tp,LOCATION_PZONE,0,nil,e,tp,zone)
	-- 检查此卡连接区是否有可用的怪兽区域空格，以及是否存在可特召的卡，若无则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 or #g==0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的卡特殊召唤到此卡的连接区，若特殊召唤失败则结束处理。
	if #sg==0 or Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP,zone)==0 then return end
	-- 无效对方的效果发动，并检查卡组中是否存在可加入额外卡组的偶数刻度「七音服」灵摆怪兽。
	if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(c84521924.tefilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择从卡组把灵摆怪兽表侧加入额外卡组。
		and Duel.SelectYesNo(tp,aux.Stringid(84521924,1)) then  --"是否从卡组把灵摆怪兽加入额外卡组？"
		-- 中断当前效果，使后续的加入额外卡组处理与前面的无效发动不视为同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要加入额外卡组的灵摆怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84521924,2))  --"请选择要加入额外卡组的灵摆怪兽"
		-- 让玩家从卡组选择1只满足条件的偶数刻度「七音服」灵摆怪兽。
		local exg=Duel.SelectMatchingCard(tp,c84521924.tefilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的灵摆怪兽表侧表示送去额外卡组。
		Duel.SendtoExtraP(exg,nil,REASON_EFFECT)
	end
end
