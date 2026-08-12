--聖天樹の開花
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，自己场上有连接4以上的植物族连接怪兽存在的场合，对方场上的全部表侧表示怪兽的效果无效化。
-- ②：自己的植物族连接怪兽进行战斗的伤害计算时才能发动。那只怪兽的攻击力直到回合结束时上升那所连接区的怪兽的攻击力的合计数值。
function c54340229.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，自己场上有连接4以上的植物族连接怪兽存在的场合，对方场上的全部表侧表示怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,54340229+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c54340229.acttg)
	e1:SetOperation(c54340229.actop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的植物族连接怪兽进行战斗的伤害计算时才能发动。那只怪兽的攻击力直到回合结束时上升那所连接区的怪兽的攻击力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54340229,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,54340230)
	e2:SetCondition(c54340229.atkcon)
	e2:SetTarget(c54340229.atktg)
	e2:SetOperation(c54340229.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上的连接4以上的植物族连接怪兽
function c54340229.lkfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_LINK) and c:IsLinkAbove(4)
end
-- 卡片发动时的效果处理（e1的Target函数）：若自己场上有连接4以上的植物族连接怪兽存在，则设置无效对方场上所有表侧表示怪兽的操作信息
function c54340229.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查自己场上是否存在连接4以上的植物族连接怪兽
	if Duel.IsExistingMatchingCard(c54340229.lkfilter,tp,LOCATION_MZONE,0,1,nil) then
		-- 获取对方场上所有可以被无效效果的表侧表示怪兽
		local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
		-- 设置效果处理信息：使对方场上这些怪兽的效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
	end
end
-- 卡片发动时的效果处理（e1的Operation函数）：若自己场上有连接4以上的植物族连接怪兽存在，则使对方场上所有表侧表示怪兽的效果无效化
function c54340229.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在连接4以上的植物族连接怪兽
	if Duel.IsExistingMatchingCard(c54340229.lkfilter,tp,LOCATION_MZONE,0,1,nil) then
		-- 获取对方场上所有可以被无效效果的表侧表示怪兽
		local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
		local tc=g:GetFirst()
		while tc do
			-- 使与该怪兽相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 对方场上的全部表侧表示怪兽的效果无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 对方场上的全部表侧表示怪兽的效果无效化。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end
-- 效果②的发动条件：自己的植物族连接怪兽进行战斗的伤害计算时
function c54340229.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己进行战斗的怪兽
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsRace(RACE_PLANT) and tc:IsType(TYPE_LINK)
end
-- 效果②的Target函数：检查进行战斗的怪兽的连接区是否存在表侧表示且攻击力大于0的怪兽
function c54340229.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己进行战斗的怪兽
	local tc=Duel.GetBattleMonster(tp)
	local lg=tc:GetLinkedGroup():Filter(Card.IsFaceup,nil)
	if chk==0 then return #lg>0 and lg:GetSum(Card.GetAttack)>0 end
end
-- 效果②的Operation函数：使进行战斗的怪兽的攻击力直到回合结束时上升其连接区怪兽的攻击力合计数值
function c54340229.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己进行战斗的怪兽
	local tc=Duel.GetBattleMonster(tp)
	if not tc:IsRelateToBattle() then return end
	local lg=tc:GetLinkedGroup():Filter(Card.IsFaceup,nil)
	-- 那只怪兽的攻击力直到回合结束时上升那所连接区的怪兽的攻击力的合计数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(lg:GetSum(Card.GetAttack))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
