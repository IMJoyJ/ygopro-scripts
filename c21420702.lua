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
-- 过滤函数，用于判断场上是否存在满足条件的「烈焰加农炮」
function c21420702.costfilter(c)
	return c:IsFaceup() and c:IsCode(69537999) and c:IsAbleToGraveAsCost()
end
-- 发动时的费用处理，选择并把场上的「烈焰加农炮」送去墓地
function c21420702.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「烈焰加农炮」
	if chk==0 then return Duel.IsExistingMatchingCard(c21420702.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「烈焰加农炮」
	local g=Duel.SelectMatchingCard(tp,c21420702.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的「烈焰加农炮」送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动时的额外费用处理，使自己在该回合不能攻击
function c21420702.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该玩家在本回合是否已经进行过攻击
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 创建并注册一个使自己怪兽不能攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于判断手卡中是否存在炎族怪兽
function c21420702.disfilter(c)
	return c:IsRace(RACE_PYRO)
end
-- 效果发动时的处理，检查是否满足发动条件
function c21420702.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查手卡中是否存在炎族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21420702.disfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查对方场上是否存在可以作为目标的怪兽
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，确定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，确定要给予对方的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	-- 设置操作信息，确定要送去墓地的炎族怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的处理，选择并破坏对方怪兽并造成伤害
function c21420702.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择手卡中的炎族怪兽
	local g=Duel.SelectMatchingCard(tp,c21420702.disfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的炎族怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 获取当前连锁中选择的目标怪兽
		local tc=Duel.GetFirstTarget()
		-- 判断目标怪兽是否仍然有效并进行破坏
		if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 对对方造成500点伤害
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
