--オルフェゴール・オーケストリオン
-- 效果：
-- 包含「自奏圣乐」怪兽的效果怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：连接状态的这张卡不会被战斗·效果破坏。
-- ②：以除外的3只自己的机械族怪兽为对象才能发动。那些怪兽回到卡组。对方场上有连接状态的表侧表示怪兽存在的场合，那些怪兽攻击力·守备力变成0，效果无效化。
function c3134857.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2张至多99张满足类型为效果怪兽的连接素材，并且这些素材中必须包含至少1张「自奏圣乐」系列的卡。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,c3134857.lcheck)
	c:EnableReviveLimit()
	-- ①：连接状态的这张卡不会被战斗·效果破坏。
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
	-- ②：以除外的3只自己的机械族怪兽为对象才能发动。那些怪兽回到卡组。对方场上有连接状态的表侧表示怪兽存在的场合，那些怪兽攻击力·守备力变成0，效果无效化。
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
-- 连接素材中必须包含至少1张「自奏圣乐」系列的卡。
function c3134857.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x11b)
end
-- 当此卡处于连接状态时，该效果生效。
function c3134857.indcon(e)
	return e:GetHandler():IsLinkState()
end
-- 当此卡不处于可以发动诱发即时效果的状态时，该效果可以发动。
function c3134857.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 当此卡不处于可以发动诱发即时效果的状态时，该效果可以发动。
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 当此卡处于可以发动诱发即时效果的状态且当前阶段为伤害步骤前时，该效果可以发动。
function c3134857.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当此卡处于可以发动诱发即时效果的状态且当前阶段为伤害步骤前时，该效果可以发动。
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp) and aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 筛选满足条件的除外区机械族怪兽，这些怪兽可以被送回卡组。
function c3134857.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck()
end
-- 设置效果目标为除外区的3只机械族怪兽，若满足条件则选择这些怪兽并设置操作信息。
function c3134857.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c3134857.tdfilter(chkc) end
	-- 检查是否存在满足条件的3只除外区机械族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c3134857.tdfilter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要送回卡组的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3只满足条件的除外区机械族怪兽作为效果目标。
	local g=Duel.SelectTarget(tp,c3134857.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置操作信息，表示将3只怪兽送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
-- 筛选满足条件的场上连接状态且表侧表示的怪兽。
function c3134857.atkfilter(c)
	return c:IsLinkState() and c:IsFaceup()
end
-- 处理效果操作，将目标怪兽送回卡组，并对对方场上的连接怪兽造成攻击力守备力归零和效果无效化。
function c3134857.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定为目标的卡，并筛选出与当前效果相关的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若目标卡存在且成功送回卡组，并且其中有卡进入卡组或额外卡组，则继续处理后续效果。
	if tg:GetCount()>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
		-- 获取对方场上的所有连接状态且表侧表示的怪兽。
		local g=Duel.GetMatchingGroup(c3134857.atkfilter,tp,0,LOCATION_MZONE,nil)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		while tc do
			-- 将目标怪兽的攻击力设置为0。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 将目标怪兽的守备力设置为0。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(0)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 使目标怪兽的效果无效化。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
			-- 使目标怪兽的效果无效化。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_DISABLE_EFFECT)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e4)
			tc=g:GetNext()
		end
	end
end
