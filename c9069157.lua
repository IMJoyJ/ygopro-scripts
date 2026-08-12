--ドラゴンロイド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。
-- ●从卡组把1只风属性以外的「机人」怪兽加入手卡。
-- ●这个回合，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：1回合1次，这张卡在墓地存在的场合才能发动。墓地的这张卡直到回合结束时变成龙族。
function c9069157.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。●从卡组把1只风属性以外的「机人」怪兽加入手卡。●这个回合，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,9069157)
	e1:SetCost(c9069157.cost)
	e1:SetTarget(c9069157.target)
	e1:SetOperation(c9069157.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡在墓地存在的场合才能发动。墓地的这张卡直到回合结束时变成龙族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c9069157.rctg)
	e2:SetOperation(c9069157.rcop)
	c:RegisterEffect(e2)
end
-- ①效果的代价：将手牌的这张卡丢弃。
function c9069157.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡作为发动代价丢弃送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 检索过滤条件：风属性以外的「机人」怪兽。
function c9069157.thfilter(c)
	return c:IsNonAttribute(ATTRIBUTE_WIND) and c:IsSetCard(0x16) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备：检测可行性并让玩家选择要发动的效果分支。
function c9069157.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足检索条件的怪兽。
	local b1=Duel.IsExistingMatchingCard(c9069157.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查本回合是否尚未适用过融合召唤保护效果。
	local b2=Duel.GetFlagEffect(tp,9069157)==0
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个分支均可行时，由玩家选择其中一个效果发动。
		op=Duel.SelectOption(tp,aux.Stringid(9069157,0),aux.Stringid(9069157,1))  --"卡组检索/融合抗性"
	elseif b1 then
		-- 仅检索效果可行时，强制选择检索效果。
		op=Duel.SelectOption(tp,aux.Stringid(9069157,0))  --"卡组检索"
	else
		-- 仅融合保护效果可行时，强制选择融合保护效果并对选项索引进行修正。
		op=Duel.SelectOption(tp,aux.Stringid(9069157,1))+1  --"融合抗性"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息：从卡组将1张卡加入手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(0)
	end
end
-- ①效果的处理：根据选择的分支执行检索或适用融合召唤保护。
function c9069157.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1只满足条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,c9069157.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 如果选择的是融合保护分支且本回合尚未适用。
	if op==1 and Duel.GetFlagEffect(tp,9069157)==0 then
		local c=e:GetHandler()
		-- 包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_INACTIVATE)
		e1:SetValue(c9069157.efilter)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册“包含融合召唤效果的效果发动不会被无效化”的全局效果。
		Duel.RegisterEffect(e1,tp)
		-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(c9069157.limcon)
		e2:SetOperation(c9069157.limop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册“融合召唤成功时限制对方发动效果”的全局事件监听效果。
		Duel.RegisterEffect(e2,tp)
		-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_END)
		e3:SetOperation(c9069157.limop2)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册“连锁结束时限制对方发动效果”的全局事件监听效果。
		Duel.RegisterEffect(e3,tp)
		-- 给玩家注册本回合已适用融合保护效果的标记。
		Duel.RegisterFlagEffect(tp,9069157,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤不会被无效化的效果：自己发动的包含融合召唤效果的效果。
function c9069157.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取当前正在处理的连锁的效果和发动玩家。
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 过滤融合召唤成功的怪兽：由自己通过包含融合召唤的效果特殊召唤的融合怪兽。
function c9069157.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT):IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 限制对方发动的条件：自己成功融合召唤了融合怪兽。
function c9069157.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c9069157.limfilter,1,nil,tp)
end
-- 限制对方发动的处理：根据当前连锁深度，直接锁定连锁或注册标记并在连锁结束时锁定。
function c9069157.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果融合召唤是在连锁0（非连锁处理中）成功。
	if Duel.GetCurrentChain()==0 then
		-- 限制对方不能在当前时点发动卡的效果（直到连锁结束）。
		Duel.SetChainLimitTillChainEnd(c9069157.chainlm)
	-- 如果融合召唤是在连锁1的效果处理中成功。
	elseif Duel.GetCurrentChain()==1 then
		-- 注册标记，表示需要在连锁结束时限制对方发动效果。
		Duel.RegisterFlagEffect(tp,9069158,0,0,1)
		-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c9069157.resetop)
		-- 注册“有新连锁发动时重置标记”的临时效果。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册“效果处理中断时重置标记”的临时效果。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置标记的处理：清除连锁结束锁定的标记并重置自身。
function c9069157.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 清除用于在连锁结束时锁定的标记。
	Duel.ResetFlagEffect(tp,9069158)
	e:Reset()
end
-- 连锁结束时的处理：如果存在锁定标记，则限制对方发动效果。
function c9069157.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果存在需要在连锁结束时锁定的标记。
	if Duel.GetFlagEffect(tp,9069158)~=0 then
		-- 限制对方不能在连锁结束后的时点发动卡的效果。
		Duel.SetChainLimitTillChainEnd(c9069157.chainlm)
	end
end
-- 连锁限制条件：只有自己可以发动效果（即对方不能发动效果）。
function c9069157.chainlm(e,rp,tp)
	return tp==rp
end
-- ②效果的发动准备：确认自身在墓地且当前不是龙族。
function c9069157.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsRace(RACE_DRAGON) end
	-- 设置操作信息：此卡将涉及离开墓地的相关处理。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的处理：使墓地的这张卡直到回合结束时变成龙族。
function c9069157.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 墓地的这张卡直到回合结束时变成龙族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
