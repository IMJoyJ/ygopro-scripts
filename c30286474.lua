--剛鬼ザ・マスター・オーガ
-- 效果：
-- 「刚鬼」怪兽2只以上
-- ①：1回合1次，让这张卡所连接区的自己的「刚鬼」怪兽任意数量回到持有者手卡，以回到手卡的数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
-- ②：这张卡可以向对方怪兽全部各作1次攻击，对方场上有表侧表示怪兽存在的场合，只能选择那之内的攻击力最高的怪兽作为攻击对象。
function c30286474.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用至少2只属于「刚鬼」的怪兽作为连接素材
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
	-- ②：这张卡可以向对方怪兽全部各作1次攻击，对方场上有表侧表示怪兽存在的场合，只能选择那之内的攻击力最高的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击，对方场上有表侧表示怪兽存在的场合，只能选择那之内的攻击力最高的怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(c30286474.atcon)
	e3:SetValue(c30286474.atlimit)
	c:RegisterEffect(e3)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击，对方场上有表侧表示怪兽存在的场合，只能选择那之内的攻击力最高的怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e4:SetCondition(c30286474.atcon)
	c:RegisterEffect(e4)
end
-- 设置效果发动时的标记，用于判断是否满足发动条件
function c30286474.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 用于筛选满足条件的怪兽作为发动效果的代价
function c30286474.costfilter(c,g)
	return c:IsFaceup() and c:IsSetCard(0xfc) and g:IsContains(c) and c:IsAbleToHandAsCost()
end
-- 设置效果的发动条件，检查是否满足发动条件
function c30286474.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 设置效果的目标选择条件，用于筛选对方场上的可无效化卡片
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查是否存在满足条件的「刚鬼」怪兽可以送入手牌作为代价
			return Duel.IsExistingMatchingCard(c30286474.costfilter,tp,LOCATION_MZONE,0,1,nil,lg)
				-- 检查是否存在满足条件的对方场上的卡片可以作为效果对象
				and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		else return false end
	end
	e:SetLabel(0)
	-- 获取满足条件的对方场上的卡片数量
	local rt=Duel.GetTargetCount(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 提示玩家选择要送入手牌的「刚鬼」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的「刚鬼」怪兽送入手牌作为代价
	local cg=Duel.SelectMatchingCard(tp,c30286474.costfilter,tp,LOCATION_MZONE,0,1,rt,nil,lg)
	local ct=cg:GetCount()
	-- 将选择的怪兽送入手牌
	Duel.SendtoHand(cg,nil,REASON_COST)
	-- 提示玩家选择要无效的对方场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择满足条件的对方场上的卡片作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置效果处理信息，记录将要无效的卡片
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 用于筛选满足条件的卡片作为效果处理对象
function c30286474.disfilter(c,e)
	-- 用于筛选满足条件的卡片作为效果处理对象
	return aux.NegateAnyFilter(c) and c:IsRelateToEffect(e)
end
-- 执行效果处理，使目标卡片的效果无效
function c30286474.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中已选择的目标卡片并筛选出满足条件的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c30286474.disfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 使目标卡片相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡片的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡片的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标为陷阱怪兽的卡片的效果无效
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
-- 设置攻击限制条件，当对方场上存在表侧表示怪兽时触发
function c30286474.atcon(e)
	-- 检查对方场上是否存在表侧表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 设置攻击限制值，限制对方不能选择攻击力最高的怪兽作为攻击对象
function c30286474.atlimit(e,c)
	-- 获取对方场上的所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	return not tg:IsContains(c) or c:IsFacedown()
end
