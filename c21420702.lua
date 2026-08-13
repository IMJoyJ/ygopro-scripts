--ブレイズ・キャノン－トライデント
-- 效果：
-- 这张卡把自己场上表侧表示存在的1张「烈焰加农炮」送去墓地才能发动。此外，自己的主要阶段时，选择对方场上1只怪兽才能发动。从手卡把1只炎族怪兽送去墓地，选择的对方怪兽破坏并给与对方基本分500分伤害。这个效果发动的回合，自己怪兽不能攻击。
function c21420702.initial_effect(c)
	-- 这张卡把自己场上表侧表示存在的1张「烈焰加农炮」送去墓地才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c21420702.cost)
	c:RegisterEffect(e1)
	-- 此外，自己的主要阶段时，选择对方场上1只怪兽才能发动。从手卡把1只炎族怪兽送去墓地，选择的对方怪兽破坏并给与对方基本分500分伤害。这个效果发动的回合，自己怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21420702,0))  --"对方场上存在的1只怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c21420702.descost)
	e2:SetTarget(c21420702.destg)
	e2:SetOperation(c21420702.desop)
	c:RegisterEffect(e2)
end
-- 过滤器：选择自己场上表侧表示、卡名为「烈焰加农炮」且可以作为代价送去墓地的卡。
function c21420702.costfilter(c)
	return c:IsFaceup() and c:IsCode(69537999) and c:IsAbleToGraveAsCost()
end
-- 发动代价：把自己场上表侧表示存在的1张「烈焰加农炮」送去墓地。
function c21420702.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：自己场上是否存在1张表侧表示且可作为代价的「烈焰加农炮」。
	if chk==0 then return Duel.IsExistingMatchingCard(c21420702.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 显示选择提示：请选择要送去墓地的卡（用于选择作为代价的「烈焰加农炮」）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己魔陷区选择1张满足costfilter条件的「烈焰加农炮」作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c21420702.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的「烈焰加农炮」作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动代价：本回合自己尚未攻击过；发动后给自己场上所有怪兽附加直到回合结束不能攻击的誓约效果（对应“这个效果发动的回合，自己怪兽不能攻击”）。
function c21420702.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己本回合是否没有进行过攻击（因为发动后自己怪兽不能攻击，所以发动前必须未攻击过）。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 此外，自己的主要阶段时，选择对方场上1只怪兽才能发动。从手卡把1只炎族怪兽送去墓地，选择的对方怪兽破坏并给与对方基本分500分伤害。这个效果发动的回合，自己怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该不能攻击的效果注册到场上，使其对己方怪兽持续适用。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤器：选择手卡中的1只炎族怪兽（用于效果处理时送去墓地）。
function c21420702.disfilter(c)
	return c:IsRace(RACE_PYRO)
end
-- 效果的目标选择与合法性检查：需要手卡存在1只炎族怪兽，并以对方场上1只怪兽为对象。
function c21420702.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 合法性检查：手卡是否存在至少1只炎族怪兽（用于效果处理时送去墓地）。
	if chk==0 then return Duel.IsExistingMatchingCard(c21420702.disfilter,tp,LOCATION_HAND,0,1,nil)
		-- 合法性检查：对方场上是否存在可以作为对象的怪兽（取对象）。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示：请选择要破坏的卡（选择对方场上1只怪兽作为对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：预定破坏对象怪兽1只。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：预定给对方造成500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	-- 设置操作信息：预定从手卡把1只炎族怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡选1只炎族怪兽送去墓地；若对象怪兽仍然存在且与效果有关联，则将其破坏并给对方500点伤害。
function c21420702.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要送去墓地的卡（从手卡选择炎族怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1只炎族怪兽。
	local g=Duel.SelectMatchingCard(tp,c21420702.disfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的炎族怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 取回发动时选择的对象怪兽。
		local tc=Duel.GetFirstTarget()
		-- 若对象怪兽仍然存在且与该效果有关联，则将其破坏；破坏成功后才继续处理伤害。
		if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方基本分500点伤害。
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
