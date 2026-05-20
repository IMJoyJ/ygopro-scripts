--デストーイ・クルーエル・ホエール
-- 效果：
-- 「锋利小鬼」怪兽＋「毛绒动物」怪兽
-- ①：这张卡融合召唤成功的场合才能发动。选自己以及对方场上的卡各1张破坏。
-- ②：1回合1次，以自己场上1只融合怪兽为对象才能发动。从卡组·额外卡组把「魔玩具·残虐虎鲸」以外的1张「魔玩具」卡送去墓地，作为对象的怪兽的攻击力直到回合结束时上升自身的原本攻击力一半数值。这个效果在对方回合也能发动。
function c78778375.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为1只「锋利小鬼」怪兽和1只「毛绒动物」怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc3),aux.FilterBoolFunction(Card.IsFusionSetCard,0xa9),true)
	-- ①：这张卡融合召唤成功的场合才能发动。选自己以及对方场上的卡各1张破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78778375,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c78778375.descon)
	e1:SetTarget(c78778375.destg)
	e1:SetOperation(c78778375.desop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只融合怪兽为对象才能发动。从卡组·额外卡组把「魔玩具·残虐虎鲸」以外的1张「魔玩具」卡送去墓地，作为对象的怪兽的攻击力直到回合结束时上升自身的原本攻击力一半数值。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78778375,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e2:SetCountLimit(1)
	-- 限制该效果在伤害步骤中不能在伤害计算后发动
	e2:SetCondition(aux.dscon)
	e2:SetTarget(c78778375.atktg)
	e2:SetOperation(c78778375.atkop)
	c:RegisterEffect(e2)
end
-- 判定此卡是否成功进行融合召唤，作为效果1的发动条件
function c78778375.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果1的发动准备：检查双方场上是否都存在卡片，并注册破坏的操作信息
function c78778375.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的所有卡片
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 获取对方场上的所有卡片
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return g1:GetCount()>0 and g2:GetCount()>0 end
	g1:Merge(g2)
	-- 设置连锁处理中的操作信息为破坏双方场上的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果1的处理：让玩家从双方场上各选择1张卡并将其破坏
function c78778375.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有卡片
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 获取对方场上的所有卡片
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示玩家选择自己场上要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg1=g1:Select(tp,1,1,nil)
		-- 提示玩家选择对方场上要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg2=g2:Select(tp,1,1,nil)
		dg1:Merge(dg2)
		if dg1:GetCount()==2 then
			-- 在场上显式展示被选择破坏的卡片
			Duel.HintSelection(dg1)
			-- 因效果破坏选中的卡片
			Duel.Destroy(dg1,REASON_EFFECT)
		end
	end
end
-- 过滤条件：自己场上表侧表示、原本攻击力大于0的融合怪兽
function c78778375.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:GetBaseAttack()>0
end
-- 过滤条件：卡组或额外卡组中「魔玩具·残虐虎鲸」以外的「魔玩具」卡片，且能送去墓地
function c78778375.tgfilter(c)
	return c:IsSetCard(0xad) and not c:IsCode(78778375) and c:IsAbleToGrave()
end
-- 效果2的发动准备：检查并选择自己场上1只融合怪兽作为对象，并注册送去墓地的操作信息
function c78778375.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c78778375.atkfilter(chkc) end
	-- 检查自己场上是否存在符合条件的融合怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c78778375.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查卡组或额外卡组是否存在符合条件的「魔玩具」卡片
		and Duel.IsExistingMatchingCard(c78778375.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的融合怪兽作为效果对象
	Duel.SelectTarget(tp,c78778375.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理中的操作信息为从卡组或额外卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果2的处理：将1张「魔玩具」卡送去墓地，并使作为对象的怪兽攻击力上升原本攻击力的一半
function c78778375.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组或额外卡组选择1张符合条件的「魔玩具」卡片
	local g=Duel.SelectMatchingCard(tp,c78778375.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	local gc=g:GetFirst()
	-- 成功将选中的卡送去墓地，且该卡确实到达墓地，同时作为对象的怪兽仍在场上表侧表示存在时
	if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetBaseAttack()
		-- 作为对象的怪兽的攻击力直到回合结束时上升自身的原本攻击力一半数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
	end
end
