--ダイナミスト・レックス
-- 效果：
-- ←6 【灵摆】 6→
-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡进行攻击的伤害步骤结束时，可以把这张卡以外的自己场上1只「雾动机龙」怪兽解放，从以下效果选择1个发动。
-- ●这张卡向对方怪兽可以继续攻击，向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ●选对方的手卡·场上1张卡回到持有者卡组（从手卡选的场合是随机选）。那之后，这张卡的攻击力上升100。
function c63251695.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63251695,0))  --"选择效果"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c63251695.negcon)
	e2:SetOperation(c63251695.negop)
	c:RegisterEffect(e2)
	-- ①：这张卡进行攻击的伤害步骤结束时，可以把这张卡以外的自己场上1只「雾动机龙」怪兽解放，从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c63251695.effcon)
	e3:SetCost(c63251695.effcost)
	e3:SetTarget(c63251695.efftg)
	e3:SetOperation(c63251695.effop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「雾动机龙」卡。
function c63251695.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd8) and c:IsControler(tp) and c:IsOnField()
end
-- 灵摆效果的发动条件：此卡未发动过该效果，且对方发动了以自己场上其他「雾动机龙」卡为对象的效果，且该效果可以被无效。
function c63251695.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(63251695)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		-- 检查对象卡片组中是否存在这张卡以外的自己场上的「雾动机龙」卡，且该连锁效果可以被无效。
		and g and g:IsExists(c63251695.tfilter,1,e:GetHandler(),tp) and Duel.IsChainDisablable(ev)
end
-- 灵摆效果的处理：玩家选择是否发动，若发动则注册已使用标记，无效该效果，并破坏这张卡。
function c63251695.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否发动该效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(63251695,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 如果成功使该连锁的效果无效。
		if Duel.NegateEffect(ev) then
			-- 中断当前效果处理，使后续的破坏处理与无效处理不视为同时进行。
			Duel.BreakEffect()
			-- 破坏这张卡。
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 怪兽效果的发动条件：这张卡进行攻击的伤害步骤结束时。
function c63251695.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡是否是攻击怪兽且仍与战斗相关。
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 怪兽效果的Cost：解放这张卡以外的自己场上1只「雾动机龙」怪兽。
function c63251695.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在这张卡以外的可以解放的「雾动机龙」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0xd8) end
	-- 玩家选择这张卡以外的自己场上1只「雾动机龙」怪兽。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0xd8)
	-- 解放选择的怪兽。
	Duel.Release(g,REASON_COST)
end
-- 怪兽效果的目标选择：检查两个分支效果是否可行，并让玩家选择其中一个发动。
function c63251695.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:GetHandler():IsChainAttackable(0,true)
	-- 检查对方手卡或场上是否存在可以回到持有者卡组的卡。
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_HAND,1,nil)
	if chk==0 then return b1 or b2 end
	local opt=0
	if b1 and b2 then
		-- 两个效果均可行时，让玩家选择“再次攻击”或“返回卡组”。
		opt=Duel.SelectOption(tp,aux.Stringid(63251695,2),aux.Stringid(63251695,3))  --"再次攻击/返回卡组"
	elseif b1 then
		-- 仅能选择再次攻击时，提示并选择“再次攻击”。
		opt=Duel.SelectOption(tp,aux.Stringid(63251695,2))  --"再次攻击"
	else
		-- 仅能选择返回卡组时，提示并选择“返回卡组”（选项索引加1以匹配分支1）。
		opt=Duel.SelectOption(tp,aux.Stringid(63251695,3))+1  --"返回卡组"
	end
	e:SetLabel(opt)
	if opt==1 then
		-- 设置效果处理信息：将对方手卡或场上的1张卡送回卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
	end
end
-- 怪兽效果的处理：根据玩家的选择，执行“追加攻击并赋予穿防效果”或“让对方手卡·场上1张卡回到卡组且自身攻击力上升100”。
function c63251695.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		if not c:IsRelateToBattle() then return end
		-- 使这张卡可以继续进行攻击。
		Duel.ChainAttack()
		-- ●这张卡向对方怪兽可以继续攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
		-- 向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e2)
	else
		-- 获取对方手卡中可以回到卡组的卡片组。
		local g1=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil)
		-- 获取对方场上可以回到卡组的卡片组。
		local g2=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
		local opt=0
		if g1:GetCount()>0 and g2:GetCount()>0 then
			-- 对方手卡和场上都有卡时，让玩家选择从“手卡”还是“场上”将卡送回卡组。
			opt=Duel.SelectOption(tp,aux.Stringid(63251695,4),aux.Stringid(63251695,5))  --"对方手卡1张卡回到持有者卡组/对方场上1张卡回到持有者卡组"
		elseif g1:GetCount()>0 then
			opt=0
		elseif g2:GetCount()>0 then
			opt=1
		else
			return
		end
		local sg=nil
		if opt==0 then
			sg=g1:RandomSelect(tp,1)
		else
			-- 提示玩家选择要返回卡组的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			sg=g2:Select(tp,1,1,nil)
		end
		-- 将选中的卡送回持有者卡组并洗牌。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if sg:GetFirst():IsLocation(LOCATION_DECK) and c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 中断当前效果处理，使后续的攻击力上升处理与返回卡组不视为同时进行。
			Duel.BreakEffect()
			-- 那之后，这张卡的攻击力上升100。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(100)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
