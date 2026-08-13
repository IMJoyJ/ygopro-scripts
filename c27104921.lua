--運命の囚人
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：连接4怪兽连接召唤的场合才能发动1次。给这张卡放置1个指示物（最多3个）。那之后，可以让这张卡的指示物数量的以下效果适用。
-- ●1个：宣言1个卡名。这个回合，原本卡名和宣言的卡相同的卡的效果无效化。
-- ●2个：从自己墓地选1只4星以下的怪兽特殊召唤。
-- ●3个：这张卡送去墓地，从额外卡组把1只连接4怪兽特殊召唤。
function c27104921.initial_effect(c)
	c:EnableCounterPermit(0x61)
	c:SetCounterLimit(0x61,3)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,27104921+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ①：连接4怪兽连接召唤的场合才能发动1次。给这张卡放置1个指示物（最多3个）。那之后，可以让这张卡的指示物数量的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c27104921.condition)
	e2:SetTarget(c27104921.target)
	e2:SetOperation(c27104921.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：判定特殊召唤成功的怪兽是否为表侧表示的连接4怪兽，且通过连接召唤登场。
function c27104921.cfilter(c,tp)
	return c:IsLink(4) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsFaceup()
end
-- 发动条件：本次特殊召唤成功的怪兽群中，是否存在一只满足上述过滤条件的连接4怪兽（即发生了连接4怪兽的连接召唤）。
function c27104921.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27104921.cfilter,1,nil,tp)
end
-- 目标与操作信息：在发动时检查能否给这张卡添加1个指示物，并设置后续处理中要添加指示物的操作信息。
function c27104921.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若为发动时点chk==0，返回能否给这张卡添加1个指示物；不能则无法发动。
	if chk==0 then return Duel.IsCanAddCounter(tp,0x61,1,e:GetHandler()) end
	-- 设置操作信息：向系统登记本次效果将给这张卡放置1个countertype为0x61的指示物，用于连锁判定与诱发检测。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x61)
end
-- 效果处理：给这张卡放置1个指示物，获取当前指示物数量，并按数量让玩家选择是否适用对应效果：1个宣言卡名无效化、2个从墓地特召4星以下怪兽、3个将自身送墓并从额外卡组特召连接4怪兽。
function c27104921.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x61,1)
		local ct=c:GetCounter(0x61)
		-- 当指示物数量为1时，询问玩家是否宣言卡名并使同名卡的效果无效化。
		if ct==1 and Duel.SelectYesNo(tp,aux.Stringid(27104921,0)) then  --"是否宣言卡名无效化？"
			-- 中断当前效果链处理，使后续的宣言卡名/特殊召唤等操作视为新的效果处理时点，避免错过时点并保证连锁正确。
			Duel.BreakEffect()
			-- 向玩家发送选择提示：请宣言一个卡名（用于Duel.AnnounceCard的交互）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
			-- 玩家宣言一个卡名并返回其卡号，用于后续判定同名卡。
			local ac=Duel.AnnounceCard(tp)
			-- 这个回合，原本卡名和宣言的卡相同的卡的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
			e1:SetTarget(c27104921.distg1)
			e1:SetLabel(ac)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 把无效化效果e1注册到场上，使其持续作用于双方场上所有符合条件的卡，直到回合结束。
			Duel.RegisterEffect(e1,tp)
			-- 这个回合，原本卡名和宣言的卡相同的卡的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVING)
			e2:SetCondition(c27104921.discon)
			e2:SetOperation(c27104921.disop)
			e2:SetLabel(ac)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 把针对连锁处理中发动效果的无效化效果e2注册到场上，用于无效宣言卡名相同的卡在连锁中发动的效果。
			Duel.RegisterEffect(e2,tp)
			-- ●1个：宣言1个卡名。这个回合，原本卡名和宣言的卡相同的卡的效果无效化。●2个：从自己墓地选1只4星以下的怪兽特殊召唤。●3个：这张卡送去墓地，从额外卡组把1只连接4怪兽特殊召唤。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(c27104921.distg2)
			e3:SetLabel(ac)
			e3:SetReset(RESET_PHASE+PHASE_END)
			-- 把针对陷阱怪兽的无效化效果e3注册到场上，使宣言卡名相同的陷阱怪兽（陷阱卡因效果变为怪兽的情况）也被无效。
			Duel.RegisterEffect(e3,tp)
		end
		-- 获取自己墓地中满足条件的4星以下怪兽群（已排除王家长眠之谷影响），用于选择特殊召唤对象。
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c27104921.spfilter1),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 当指示物数量为2且存在可特殊召唤的墓地怪兽时，询问玩家是否从墓地特殊召唤1只4星以下的怪兽。
		if ct==2 and g1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(27104921,1)) then  --"是否从墓地特殊召唤？"
			-- 中断当前效果处理，使特殊召唤作为新的效果处理时点。
			Duel.BreakEffect()
			-- 向玩家发送选择提示：请选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg1=g1:Select(tp,1,1,nil)
			-- 将选择的1只墓地怪兽以表侧攻击表示特殊召唤到己方场上。
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 获取额外卡组中满足条件的连接4怪兽群，用于选择特殊召唤对象。
		local g2=Duel.GetMatchingGroup(c27104921.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp)
		-- 当指示物数量为3、存在可特殊召唤的连接4怪兽且这张卡能被送去墓地时，询问玩家是否适用从额外卡组特殊召唤的效果。
		if ct==3 and g2:GetCount()>0 and c:IsAbleToGrave() and Duel.SelectYesNo(tp,aux.Stringid(27104921,2)) then  --"是否从额外卡组特殊召唤？"
			-- 中断当前效果处理，使送墓和特殊召唤作为新的效果处理时点。
			Duel.BreakEffect()
			-- 把这张卡送去墓地作为发动条件，并确认确实送墓成功且位于墓地后才继续处理特殊召唤。
			if Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE) then
				-- 向玩家发送选择提示：请选择要特殊召唤的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg2=g2:Select(tp,1,1,nil)
				-- 将选择的额外卡组连接4怪兽以表侧攻击表示特殊召唤到己方场上。
				Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 定义1个指示物无效化效果的适用对象：魔法・陷阱卡只要原本卡名匹配即无效；怪兽卡则还需为效果怪兽或有原本效果怪兽类型时才无效。
function c27104921.distg1(e,c)
	local ac=e:GetLabel()
	if c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsOriginalCodeRule(ac)
	else
		return c:IsOriginalCodeRule(ac) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
	end
end
-- 用于陷阱怪兽无效化：只要原本卡名等于宣言卡名即可成为无效对象。
function c27104921.distg2(e,c)
	local ac=e:GetLabel()
	return c:IsOriginalCodeRule(ac)
end
-- 连锁无效化发动条件：检测当前连锁中发动的效果所属的卡，其原本卡名是否等于宣言卡名。
function c27104921.discon(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	return re:GetHandler():IsOriginalCodeRule(ac)
end
-- 连锁无效化处理：将满足条件的正在发动的效果无效化。
function c27104921.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行无效化：将当前连锁中编号为ev的效果无效（使该效果不处理）。
	Duel.NegateEffect(ev)
end
-- 墓地特殊召唤的过滤条件：选择4星以下的怪兽，且可用当前效果特殊召唤。
function c27104921.spfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 额外卡组特殊召唤的过滤条件：选择连接4的怪兽，且可用当前效果特殊召唤。
function c27104921.spfilter2(c,e,tp)
	return c:IsLink(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
