--オルフェゴール・オーケストリオン
-- 效果：
-- 包含「自奏圣乐」怪兽的效果怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：连接状态的这张卡不会被战斗·效果破坏。
-- ②：以除外的3只自己的机械族怪兽为对象才能发动。那些怪兽回到卡组。对方场上有连接状态的表侧表示怪兽存在的场合，那些怪兽攻击力·守备力变成0，效果无效化。
function c3134857.initial_effect(c)
	-- 为这张卡注册连接召唤手续：需要2~99只效果怪兽作为素材，且素材组中必须包含至少1只「自奏圣乐」怪兽（由lcheck额外检查）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,c3134857.lcheck)
	c:EnableReviveLimit()
	-- ①：连接状态的这张卡不会被战斗·效果破坏。（本段实现“不会被战斗破坏”部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c3134857.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：以除外的3只自己的机械族怪兽为对象才能发动。那些怪兽回到卡组。对方场上有连接状态的表侧表示怪兽存在的场合，那些怪兽攻击力·守备力变成0，效果无效化。（本段以起动效果的形式实现②效果）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3134857,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,3134857)
	e3:SetCondition(c3134857.tdcon1)
	e3:SetTarget(c3134857.tdtg)
	e3:SetOperation(c3134857.tdop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e4:SetCondition(c3134857.tdcon2)
	c:RegisterEffect(e4)
end
-- 检查连接素材中是否存在至少1只卡名含有「自奏圣乐」（0x11b）的怪兽，满足连接召唤素材条件。
function c3134857.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x11b)
end
-- ①效果的条件：这张卡处于连接状态（即作为连接怪兽被连接指向）。
function c3134857.indcon(e)
	return e:GetHandler():IsLinkState()
end
-- ②效果作为起动效果（1速）的发动条件：当前该卡未被赋予二速发动能力（不能作为诱发即时效果发动）。
function c3134857.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 当该卡不能被二速化时返回true，允许②效果以通常起动的速度发动。
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- ②效果作为诱发即时效果（2速）的发动条件：满足伤害步骤限制，且该卡被允许作为二速效果发动。
function c3134857.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回值需要同时满足：不处于伤害计算后/伤害步骤限制条件（aux.dscon），且该卡被允许作为二速效果发动。
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp) and aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- ②效果取对象的筛选条件：除外区的表侧表示机械族怪兽，且能够返回卡组。
function c3134857.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck()
end
-- ②效果的目标指定：从除外区选择3张自己的表侧机械族怪兽作为对象，并设置回卡组的操作信息。
function c3134857.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c3134857.tdfilter(chkc) end
	-- 发动合法性检查：存在至少3张符合条件的除外机械族怪兽可选作对象。
	if chk==0 then return Duel.IsExistingTarget(c3134857.tdfilter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 弹出选择提示，让玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家从自己的除外区选择3张符合条件的机械族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c3134857.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置操作信息：将选择的3张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
-- 筛选对方场上连接状态且表侧表示的怪兽，作为后续攻击力·守备力变为0和效果无效化的对象。
function c3134857.atkfilter(c)
	return c:IsLinkState() and c:IsFaceup()
end
-- ②效果处理：先将对象怪兽返回卡组（洗牌）；若返回成功且其中有卡回到卡组/额外卡组，则将对方场上连接状态表侧怪兽的攻击力·守备力变成0，效果无效化。
function c3134857.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁的对象卡，并过滤掉已与效果失去联系（如离场）的卡，得到仍有效的对象组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若仍有对象卡存在，且成功将它们返回卡组（洗牌），并且其中有卡确实位于卡组或额外卡组，则继续执行后续无效化处理。
	if tg:GetCount()>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
		-- 获取对方场上所有连接状态且表侧表示的怪兽，用于施加攻击力·守备力变成0和效果无效化。
		local g=Duel.GetMatchingGroup(c3134857.atkfilter,tp,0,LOCATION_MZONE,nil)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		while tc do
			-- 对方场上有连接状态的表侧表示怪兽存在的场合，那些怪兽攻击力·守备力变成0，效果无效化。——将攻击力设为0。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 对方场上有连接状态的表侧表示怪兽存在的场合，那些怪兽攻击力·守备力变成0，效果无效化。——将守备力设为0。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(0)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 对方场上有连接状态的表侧表示怪兽存在的场合，那些怪兽攻击力·守备力变成0，效果无效化。——使怪兽的效果无效化（无效卡的效果部分）。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
			-- 对方场上有连接状态的表侧表示怪兽存在的场合，那些怪兽攻击力·守备力变成0，效果无效化。——使怪兽的效果无效化（无效已适用的效果部分）。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_DISABLE_EFFECT)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e4)
			tc=g:GetNext()
		end
	end
end
