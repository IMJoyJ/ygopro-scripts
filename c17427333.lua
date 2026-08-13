--E.M.R.
-- 效果：
-- ①：把自己场上1只机械族怪兽解放，以解放的怪兽的原本攻击力每1000最多1张的场上的卡为对象才能发动。那些卡破坏。
function c17427333.initial_effect(c)
	-- ①：把自己场上1只机械族怪兽解放，以解放的怪兽的原本攻击力每1000最多1张的场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17427333.cost)
	e1:SetTarget(c17427333.target)
	e1:SetOperation(c17427333.operation)
	c:RegisterEffect(e1)
end
-- 发动时点检查代价：将效果标签标记为100以表明后续可以选择并支付解放代价，返回true；实际解放操作在目标选择阶段完成。
function c17427333.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		return true
	end
end
-- 筛选可作为解放的机械族怪兽：必须是机械族，且（由自己控制或表侧表示），原本攻击力至少1000，并且场上还存在其他可成为破坏对象的卡。
function c17427333.costfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and (c:IsControler(tp) or c:IsFaceup()) and c:GetTextAttack()>=1000
		-- 确认场上存在至少1张除这张解放怪兽以外的卡能够成为破坏对象（保证有对象可选）。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 目标选择处理：确认代价标记后，选择要解放的机械族怪兽，以其原本攻击力每1000决定最多可选破坏数量，并选择场上对应数量的卡作为效果对象，同时设置破坏信息。
function c17427333.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足costfilter条件的可解放机械族怪兽作为代价。
		return Duel.CheckReleaseGroup(tp,c17427333.costfilter,1,nil,tp)
	end
	-- 从自己场上选择1只满足costfilter条件的机械族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c17427333.costfilter,1,1,nil,tp)
	local atk=g:GetFirst():GetTextAttack()
	-- 将选择的怪兽解放，作为效果发动的代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
	local ct=math.floor(atk/1000)
	local exc=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then exc=e:GetHandler() end
	-- 向玩家显示“请选择要破坏的卡”的提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 在场上选择1到ct张卡作为效果对象（ct为解放怪兽原本攻击力每1000可破坏的数量；若本卡效果未生效则排除本卡）。
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,exc)
	-- 设置本次连锁将要进行的破坏操作信息，目标为已选择的g1，数量为g1的卡数，分类为破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- 效果处理时，取得当前连锁的对象中仍与效果关联的卡，并将它们全部破坏。
function c17427333.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象，并筛选出仍与该效果存在关联的卡（离场等导致联系重置的卡会被排除）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将筛选出的卡以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
