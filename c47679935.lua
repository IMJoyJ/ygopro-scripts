--暴走魔法陣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「召唤师 阿莱斯特」加入手卡。
-- ②：只要这张卡在场地区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
function c47679935.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「召唤师 阿莱斯特」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,47679935+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c47679935.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在场地区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(c47679935.efilter)
	c:RegisterEffect(e2)
	-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c47679935.limcon)
	e3:SetOperation(c47679935.limop)
	c:RegisterEffect(e3)
	-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_CHAIN_END)
	e5:SetOperation(c47679935.limop2)
	c:RegisterEffect(e5)
end
-- 定义检索过滤条件：卡名必须是「召唤师 阿莱斯特」（86120751）且能够加入手卡。
function c47679935.thfilter(c)
	return c:IsCode(86120751) and c:IsAbleToHand()
end
-- 发动时的效果处理：从卡组选出符合条件的「召唤师 阿莱斯特」，经玩家确认后将其加入手卡并向对方展示。
function c47679935.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己卡组中所有满足thfilter条件的卡（「召唤师 阿莱斯特」且可加入手卡）的集合。
	local g=Duel.GetMatchingGroup(c47679935.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若存在候选卡，询问玩家是否发动检索效果，玩家选择“是”时才继续处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(47679935,0)) then  --"是否从卡组把「召唤师 阿莱斯特」加入手卡？"
		-- 向玩家显示选择提示：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示所选的卡，确认检索行为。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义“发动不能被无效化”的判定条件：当前连锁的效果由本卡控制者发动，且该效果包含融合召唤类别。
function c47679935.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取当前连锁的效果对象及其发动玩家，用于判断是否满足“自己发动含融合召唤类别效果”的条件。
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 定义融合召唤成功怪兽的过滤条件：由tp玩家进行融合召唤，且该特殊召唤是经由包含融合召唤类别的效果处理完成的。
function c47679935.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT):IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 判断本次特殊召唤成功事件中是否存在至少1只满足融合召唤条件的怪兽（即是否发生了符合条件的融合召唤）。
function c47679935.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47679935.limfilter,1,nil,tp)
end
-- 融合召唤成功时的处理：根据当前连锁状态决定如何施加“对方不能发动效果”的限制；若连锁数为0直接限制，若为1则挂起标记等待后续处理。
function c47679935.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否没有正在处理的连锁（融合召唤不是在连锁处理中发生的）。
	if Duel.GetCurrentChain()==0 then
		-- 设置直到连锁结束的发动限制，使对方不能发动魔法·陷阱·怪兽效果。
		Duel.SetChainLimitTillChainEnd(c47679935.chainlm)
	-- 判断当前是否处于连锁数为1的连锁处理中（融合召唤由连锁中某效果引发）。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(47679935,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c47679935.resetop)
		-- 将监听后续效果发动的临时效果e1注册到tp玩家，用于在下一个效果发动时清除标记。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 将监听效果处理结算的临时效果e2注册到tp玩家，用于在效果结算时清除标记。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 定义重置操作：清除标记并自我重置临时效果，避免限制误持续。
function c47679935.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(47679935)
	e:Reset()
end
-- 连锁结束时的处理：若标记存在则设置直到连锁结束的限制，然后清除标记；确保融合召唤发生在连锁中时限制仍生效。
function c47679935.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(47679935)~=0 then
		-- 设置直到连锁结束的连锁发动限制（由chainlm判断，仅允许本卡控制者发动），从而使对方不能发动效果。
		Duel.SetChainLimitTillChainEnd(c47679935.chainlm)
	end
	e:GetHandler():ResetFlagEffect(47679935)
end
-- 定义连锁限制规则：仅当尝试发动效果的玩家是本卡控制者时才允许发动，从而实现对方不能发动魔法·陷阱·怪兽效果。
function c47679935.chainlm(e,rp,tp)
	return tp==rp
end
