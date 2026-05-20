--ヴァレルシュラウド・ドラゴン
-- 效果：
-- 效果怪兽3只以上
-- ①：对方不能把场上的这张卡解放。
-- ②：1回合1次，自己·对方的主要阶段，以自己场上1只「弹丸」怪兽为对象才能发动（对方不能对应这个发动把卡的效果发动）。对方场上1张表侧表示卡的效果无效。那之后，作为对象的怪兽破坏。
-- ③：只在这张卡表侧表示存在才有1次，自己·对方的战斗阶段开始时才能发动。从额外卡组把1只连接4以下的「枪管」连接怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册连接召唤手续、不能解放的永续效果、无效并破坏的诱发即时效果，以及战斗阶段开始时特殊召唤额外卡组怪兽的诱发效果。
function s.initial_effect(c)
	-- 添加连接召唤手续：效果怪兽3只以上。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：对方不能把场上的这张卡解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.rellimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己·对方的主要阶段，以自己场上1只「弹丸」怪兽为对象才能发动（对方不能对应这个发动把卡的效果发动）。对方场上1张表侧表示卡的效果无效。那之后，作为对象的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效并破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：只在这张卡表侧表示存在才有1次，自己·对方的战斗阶段开始时才能发动。从额外卡组把1只连接4以下的「枪管」连接怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 限制不能解放的目标为这张卡自身。
function s.rellimit(e,c,tp)
	return c==e:GetHandler()
end
-- 效果②的发动条件：自己或对方的主要阶段。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 过滤自己场上表侧表示的「弹丸」怪兽。
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x102)
end
-- 效果②的发动准备：检查对方场上是否存在可无效的表侧表示卡，并选择自己场上1只表侧表示的「弹丸」怪兽作为对象，设置破坏与无效的操作信息，并限制对方不能对应发动效果。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取对方场上所有可以被无效的表侧表示卡片。
	local sg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
	-- 检查可行性：对方场上有可无效的卡，且自己场上有可作为对象的「弹丸」怪兽。
	if chk==0 then return sg:GetCount()>0 and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择自己场上1只表侧表示的「弹丸」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息：包含破坏选择的「弹丸」怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息：包含无效对方场上卡片的效果的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
	-- 限制连锁：对方不能对应这个发动把卡的效果发动。
	Duel.SetChainLimit(s.chainlm)
end
-- 连锁限制条件：只有发动效果的玩家自己可以进行连锁（即对方不能连锁）。
function s.chainlm(e,ep,tp)
	return tp==ep
end
-- 效果②的效果处理：选择对方场上1张表侧表示卡效果无效，那之后将作为对象的「弹丸」怪兽破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「弹丸」怪兽。
	local tc=Duel.GetFirstTarget()
	-- 重新获取对方场上当前可无效的表侧表示卡片。
	local sg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if sg:GetCount()>0 then
		-- 提示玩家选择要无效的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		local tg=sg:Select(tp,1,1,nil)
		-- 闪烁显示被选择无效的对方卡片。
		Duel.HintSelection(tg)
		local sc=tg:GetFirst()
		if not sc:IsCanBeDisabledByEffect(e) then return end
		-- 使与该卡相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(sc,RESET_TURN_SET)
		-- 对方场上1张表侧表示卡的效果无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		sc:RegisterEffect(e3)
		if sc:IsType(TYPE_TRAPMONSTER) then
			local e4=e2:Clone()
			e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			sc:RegisterEffect(e4)
		end
		-- 立即刷新场上卡片的无效状态。
		Duel.AdjustInstantly(sc)
		if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
			-- 中断当前效果处理，使之后的效果处理视为不同时处理。
			Duel.BreakEffect()
			-- 破坏作为对象的「弹丸」怪兽。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 过滤额外卡组中连接4以下的「枪管」连接怪兽，且该怪兽可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x10f) and c:IsType(TYPE_LINK) and c:IsLinkBelow(4)
		-- 检查该怪兽是否能被特殊召唤，且额外怪兽区域或连接端有可用的特殊召唤位置。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③的发动准备：检查额外卡组是否存在符合条件的「枪管」怪兽，注册只在表侧表示存在才有1次发动的标志，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：额外卡组是否存在可特殊召唤的连接4以下的「枪管」连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已发动过③的效果"
	-- 设置连锁信息：包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的效果处理：从额外卡组选择1只连接4以下的「枪管」连接怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的「枪管」连接怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的怪兽以表侧表示特殊召唤。
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
