--剛鬼ザ・マスター・オーガ
-- 效果：
-- 「刚鬼」怪兽2只以上
-- ①：1回合1次，让这张卡所连接区的自己的「刚鬼」怪兽任意数量回到持有者手卡，以回到手卡的数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
-- ②：这张卡可以向对方怪兽全部各作1次攻击，对方场上有表侧表示怪兽存在的场合，只能选择那之内的攻击力最高的怪兽作为攻击对象。
function c30286474.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只以上「刚鬼」连接怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2)
	c:EnableReviveLimit()
	-- ①：1回合1次，让这张卡所连接区的自己的「刚鬼」怪兽任意数量回到持有者手卡，以回到手卡的数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30286474,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1)
	e1:SetCost(c30286474.discost)
	e1:SetTarget(c30286474.distg)
	e1:SetOperation(c30286474.disop)
	c:RegisterEffect(e1)
	-- 这张卡可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 对方场上有表侧表示怪兽存在的场合，只能选择那之内的攻击力最高的怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(c30286474.atcon)
	e3:SetValue(c30286474.atlimit)
	c:RegisterEffect(e3)
	-- 对方场上有表侧表示怪兽存在的场合，只能选择那之内的攻击力最高的怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e4:SetCondition(c30286474.atcon)
	c:RegisterEffect(e4)
end
-- 代价判定函数：将效果标签置为1，表示发动时已确认可执行返回手卡的代价，同时许可效果发动。
function c30286474.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤可返回手卡的「刚鬼」怪兽：必须是表侧表示、属于「刚鬼」字段、位于这张卡所连接区，并且可以作为代价返回手卡。
function c30286474.costfilter(c,g)
	return c:IsFaceup() and c:IsSetCard(0xfc) and g:IsContains(c) and c:IsAbleToHandAsCost()
end
-- 效果发动时的对象选择处理：确认存在可返回的怪兽与可无效的对象后，选择1至对方可无效卡数量的连接区「刚鬼」怪兽返回手卡，再选择等量的对方场上表侧表示卡作为对象，并设置无效化操作信息。
function c30286474.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 验证选择的对象：必须是对方场上表侧表示、能被无效化且在当前场上（可作为对象）的卡。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在至少1只满足返回手卡代价条件的「刚鬼」怪兽。
			return Duel.IsExistingMatchingCard(c30286474.costfilter,tp,LOCATION_MZONE,0,1,nil,lg)
				-- 检查对方场上是否存在至少1只可作为对象的可无效化表侧表示卡。
				and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		else return false end
	end
	e:SetLabel(0)
	-- 计算对方场上可被无效的卡的数量，作为可返回手卡的「刚鬼」怪兽数量上限。
	local rt=Duel.GetTargetCount(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 向操作玩家显示“请选择要返回手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1至rt张位于连接区且满足条件的「刚鬼」怪兽，作为返回手卡的代价。
	local cg=Duel.SelectMatchingCard(tp,c30286474.costfilter,tp,LOCATION_MZONE,0,1,rt,nil,lg)
	local ct=cg:GetCount()
	-- 将选中的「刚鬼」怪兽返回持有者手卡，该操作作为发动代价（REASON_COST）。
	Duel.SendtoHand(cg,nil,REASON_COST)
	-- 向操作玩家显示“请选择要无效的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方场上选择ct张表侧表示且可被无效的卡，作为本效果的对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置当前连锁的操作信息：本效果使这些对象卡无效（CATEGORY_DISABLE）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 处理时过滤对象：对象仍为可被无效的卡且与当前效果保有联系。
function c30286474.disfilter(c,e)
	-- 判断该卡是否仍能被无效化，并且是否仍然与本效果相关（未离场或联系未重置）。
	return aux.NegateAnyFilter(c) and c:IsRelateToEffect(e)
end
-- 效果处理：将当前连锁对象中仍合法的卡逐张赋予“效果无效”状态直到回合结束；对陷阱怪兽追加无效陷阱怪兽的处理。
function c30286474.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁记录的对象中，筛选出仍可被无效且与本效果相关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c30286474.disfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 使该对象卡相关联的连锁效果无效化，该无效状态在卡变里侧表示时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那些卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那些卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那些卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
-- 条件函数：检测对方场上是否存在表侧表示怪兽。
function c30286474.atcon(e)
	-- 判断对方场上是否存在至少1只表侧表示怪兽。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 攻击对象限制函数：对方场上有表侧表示怪兽时，这张卡只能选择其中攻击力最高的怪兽作为攻击对象；其他怪兽或里侧表示的怪兽不能被选择。
function c30286474.atlimit(e,c)
	-- 获取对方场上全部表侧表示怪兽组成的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	return not tg:IsContains(c) or c:IsFacedown()
end
