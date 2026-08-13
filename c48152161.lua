--神属の堕天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只「堕天使」怪兽送去墓地才能发动。选场上1只效果怪兽，那个效果直到回合结束时无效，自己基本分回复那只怪兽的攻击力的数值。
function c48152161.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡以及自己场上的表侧表示怪兽之中把1只「堕天使」怪兽送去墓地才能发动。选场上1只效果怪兽，那个效果直到回合结束时无效，自己基本分回复那只怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,48152161+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c48152161.cost)
	e1:SetTarget(c48152161.target)
	e1:SetOperation(c48152161.activate)
	c:RegisterEffect(e1)
end
-- 代价筛选函数：返回可作为发动代价的「堕天使」怪兽（在手牌或自己场上表侧表示、且可送去墓地），并保证场上存在其他可被无效的表侧效果怪兽，以满足发动条件。
function c48152161.costfilter(c)
	return c:IsSetCard(0xef)
		and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		-- 额外检查场上是否存在至少1只除候选怪兽c以外的、可以被无效的表侧效果怪兽，确保发动时必有无效对象。
		and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 代价处理函数：先检查手牌和自己场上是否存在满足条件的「堕天使」怪兽，若存在则让玩家选择1张送去墓地作为发动代价。
function c48152161.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前合法性检查：当chk==0时，确认手牌和自己场上有满足costfilter条件的「堕天使」怪兽可送墓，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c48152161.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示“请选择要送去墓地的卡”，引导玩家选择要送去墓地的代价卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌和自己场上表侧表示怪兽中选出1张满足costfilter条件的「堕天使」怪兽。
	local g=Duel.SelectMatchingCard(tp,c48152161.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的卡以“代价”方式送去墓地，完成发动所需COST。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标选择函数：发动时确认场上存在可被无效的表侧效果怪兽；由于效果处理时才选择对象，这里只登记无效效果类别，不锁定对象。
function c48152161.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查场上是否有至少1只可被无效的表侧效果怪兽，作为该卡发动的必要前提条件。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 将本次连锁的操作信息登记为“无效效果”类别，数量1张，具体目标在处理时选择（因此传nil）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
-- 效果处理函数：从场上选择1只表侧效果怪兽（排除发动卡自身），若其不免疫此效果，则将其效果无效化直到回合结束，并回复该怪兽攻击力数值的LP。
function c48152161.activate(e,tp,eg,ep,ev,re,r,rp)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	-- 显示选择提示“请选择要无效的卡”，引导玩家选择要无效化的场上表侧效果怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从场上选择1只满足aux.NegateEffectMonsterFilter（表侧效果怪兽且未被无效）的怪兽作为无效对象。
	local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,exc)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		-- 使与该怪兽相关的连锁效果无效化，并在其变里侧表示时重置此无效化状态。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那个效果直到回合结束时无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那个效果直到回合结束时无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 手动刷新该怪兽的无效状态，使刚附加的无效效果立即生效，准确更新卡片状态。
		Duel.AdjustInstantly(tc)
		local atk=tc:GetAttack()
		if atk>0 then
			-- 按被无效怪兽的攻击力数值回复自己基本分（攻击力>0时执行），回复原因标记为效果。
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
