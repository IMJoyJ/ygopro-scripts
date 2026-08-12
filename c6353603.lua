--暗炎星－ユウシ
-- 效果：
-- 1回合1次，这张卡给与对方基本分战斗伤害时，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。此外，1回合1次，把自己场上表侧表示存在的1张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。选择场上1只怪兽破坏。
function c6353603.initial_effect(c)
	-- 1回合1次，这张卡给与对方基本分战斗伤害时，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6353603,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCountLimit(1)
	e1:SetCondition(c6353603.setcon)
	e1:SetTarget(c6353603.settg)
	e1:SetOperation(c6353603.setop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把自己场上表侧表示存在的1张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。选择场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6353603,1))  --"怪兽破坏"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c6353603.destg)
	e2:SetOperation(c6353603.desop)
	c:RegisterEffect(e2)
end
-- 判定给与对方玩家战斗伤害的条件（伤害接收方不是自己）。
function c6353603.setcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤卡组中名字带有「炎舞」且可以盖放的魔法卡。
function c6353603.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 盖放效果的发动准备与合法性检测（检查卡组中是否存在可盖放的「炎舞」魔法卡）。
function c6353603.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足过滤条件的「炎舞」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c6353603.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的处理（从卡组选择1张「炎舞」魔法卡在自己场上盖放）。
function c6353603.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「炎舞」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c6353603.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡在自己场上盖放。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤自己场上表侧表示、可以送去墓地作为代价的「炎舞」魔法·陷阱卡，且场上存在除该卡以外的怪兽作为破坏对象。
function c6353603.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		-- 检查场上是否存在至少1只怪兽作为可选的破坏对象（排除当前过滤的卡）。
		and Duel.IsExistingTarget(aux.TRUE,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 破坏效果的发动准备与对象选择（包含「炎星仙-鹫真人」的免代价判定、支付送墓代价、选择破坏对象）。
function c6353603.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查自己场上是否存在可作为代价送去墓地的「炎舞」魔陷。
	if chk==0 then return Duel.IsExistingMatchingCard(c6353603.filter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or (Duel.IsPlayerAffectedByEffect(tp,46241344) and Duel.IsExistingTarget(aux.TRUE,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)) end
	-- 检查是否需要且能够通过正常送墓「炎舞」魔陷来支付发动代价。
	if Duel.IsExistingMatchingCard(c6353603.filter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择1张要送去墓地的「炎舞」魔陷。
		local g1=Duel.SelectMatchingCard(tp,c6353603.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选择的卡送去墓地作为发动代价。
		Duel.SendtoGrave(g1,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果的对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 破坏效果的处理（破坏选中的对象怪兽）。
function c6353603.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
