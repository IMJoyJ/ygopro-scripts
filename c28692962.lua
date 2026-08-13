--紫宵の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
-- ②：以自己场上1只「机界骑士」怪兽为对象才能发动。那只怪兽直到下次的自己回合的准备阶段除外，从卡组把「紫宵之机界骑士」以外的1只「机界骑士」怪兽加入手卡。这个效果在对方回合也能发动。
function c28692962.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：相同纵列有卡2张以上存在的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,28692962+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c28692962.hspcon)
	e1:SetValue(c28692962.hspval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1只「机界骑士」怪兽为对象才能发动。那只怪兽直到下次的自己回合的准备阶段除外，从卡组把「紫宵之机界骑士」以外的1只「机界骑士」怪兽加入手卡。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28692962,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,28692963)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetTarget(c28692962.thtg)
	e2:SetOperation(c28692962.thop)
	c:RegisterEffect(e2)
end
-- 筛选出所在纵列存在其他卡的卡，即该卡所在纵列至少有2张卡，用于定位满足①条件的纵列。
function c28692962.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- ①特殊召唤规则的发动条件：检查场上是否存在满足“相同纵列有卡2张以上”的纵列，并且自己场上对应纵列有可用的主怪兽区域，若是则可以从手卡往该纵列特殊召唤。
function c28692962.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 获取双方场上所有满足 cfilter 的卡，即所有处于“相同纵列有卡2张以上”的卡，这些卡所在的纵列是可能特召的位置。
	local lg=Duel.GetMatchingGroup(c28692962.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些参考卡，逐一累积它们对应的主怪兽区域。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 判断在计算得到的可特召区域中是否存在空位，从而确认能否从手卡进行规则特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- ①特殊召唤的处理值：计算所有满足条件的纵列对应的主怪兽区域，返回区域列表（zone），并以默认表侧表示进行特殊召唤。
function c28692962.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 同 hspcon 中的操作：取得场上所有处于“相同纵列有卡2张以上”的卡，用于计算可特召区域。
	local lg=Duel.GetMatchingGroup(c28692962.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡，将每张卡对应的主怪兽区域合并到 zone 中。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- ②效果选择对象的过滤条件：表侧表示的「机界骑士」怪兽，且可以被除外。
function c28692962.rmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10c) and c:IsAbleToRemove()
end
-- 检索过滤条件：卡组中「机界骑士」怪兽，且卡名不是「紫宵之机界骑士」，并且可以被加入手卡。
function c28692962.thfilter(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and not c:IsCode(28692962) and c:IsAbleToHand()
end
-- ②效果发动前检查：确认自己场上存在1只符合条件的「机界骑士」怪兽可作对象，且卡组中存在可检索的「机界骑士」怪兽，满足条件才可发动。
function c28692962.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28692962.rmfilter(chkc) end
	-- 发动时（chk==0）检查是否存在符合条件的取对象目标：自己场上1只可除外的表侧「机界骑士」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c28692962.rmfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查卡组是否存在1只符合检索条件的「机界骑士」怪兽，即可检索的组件是否齐全。
		and Duel.IsExistingMatchingCard(c28692962.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给玩家显示选择提示：请选择要除外的怪兽（HINTMSG_REMOVE 对应的文字）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 由玩家选择自己场上1只符合条件的「机界骑士」怪兽，并将其登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,c28692962.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记操作信息：本连锁将进行除外操作，对象为选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 登记操作信息：本连锁还将进行从卡组加入手卡的操作，由于处理时才能确定数量为1，来源为玩家 tp 的卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：先将对象怪兽暂时除外，若成功，则为其注册在准备阶段返回场上的效果，并从卡组检索1只符合条件的「机界骑士」怪兽加入手卡。
function c28692962.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与此效果关联后，以“效果+暂时除外”的原因将其除外；若除外成功且怪兽位于除外区，继续执行后续处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0
		and tc:IsLocation(LOCATION_REMOVED) then
		-- 那只怪兽直到下次的自己回合的准备阶段除外，从卡组把「紫宵之机界骑士」以外的1只「机界骑士」怪兽加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(28692962,1))  --"除外的怪兽回到场上"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c28692962.retcon)
		e1:SetOperation(c28692962.retop)
		-- 判断发动时是否处于己方回合的准备阶段（或更早），以决定返回效果的持续回合数：如果是准备阶段发动，则需跳过当前回合，让怪兽在下下次己方准备阶段返回。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<=PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 将返回效果的值设为当前回合数，供条件函数排除当前回合，防止在准备阶段发动后立即在当前准备阶段触发返回。
			e1:SetValue(Duel.GetTurnCount())
			tc:RegisterFlagEffect(28692962,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
			tc:RegisterFlagEffect(28692962,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
		end
		-- 将“除外怪兽在准备阶段返回场上”的持续效果注册到场上，使其在后续准备阶段生效。
		Duel.RegisterEffect(e1,tp)
		-- 提示玩家选择要加入手卡的「机界骑士」怪兽（HINTMSG_ATOHAND 对应的文字）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从己方卡组选择1张满足检索条件的「机界骑士」怪兽（排除紫宵之机界骑士）。
		local g=Duel.SelectMatchingCard(tp,c28692962.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手卡（加入其持有者的手卡），作为②的检索处理。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方确认刚才检索加入手卡的卡，以进行验证。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 返回效果的条件：只有在己方回合的准备阶段，且不是发动②的那个回合（避免立即返回），并且被除外的怪兽仍带有效果标志时，才允许返回场上。
function c28692962.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前不是己方回合，或当前回合与发动回合相同（准备阶段发动的情况），则不能触发返回；否则允许。
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():GetFlagEffect(28692962)~=0
end
-- 返回效果的操作：取出被暂时除外的对象怪兽，执行返回场上。
function c28692962.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将被除外的怪兽恢复到场上（默认以离场前的表示形式返回其原控制者的怪兽区）。
	Duel.ReturnToField(tc)
end
