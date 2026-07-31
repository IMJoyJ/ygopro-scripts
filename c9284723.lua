--ヴェノム・ボア
-- 效果：
-- 1回合只有1次，可以给对方场上1只怪兽放置2个毒指示物。这个效果使用的回合这只怪兽不能攻击宣言。
function c9284723.initial_effect(c)
	-- 1回合1次，可以给对方场上1只怪兽放置2个毒指示物。这个效果使用的回合这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9284723,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c9284723.cost)
	e1:SetTarget(c9284723.target)
	e1:SetOperation(c9284723.operation)
	c:RegisterEffect(e1)
end
c9284723.mentioned_counter={
	[0x1009]=true,
}
-- 效果Cost：检查自身本回合未进行攻击宣言，并注册本回合禁止攻击宣言的约束效果
function c9284723.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 注册单体限制效果：本回合限制自身不能进行攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果发动准备与目标选择：选择对方场上1只可以放置毒指示物的怪兽为对象
function c9284723.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1009,2) end
	-- 检查对方场上是否存在可以放置2个毒指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1009,2) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1009,2)
	-- 设置连锁操作信息：放置2个毒指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0)
end
-- 效果处理：为目标怪兽放置2个毒指示物，若攻击力因此降为0则触发自定义破坏事件
function c9284723.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁设定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1009,2) then
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,2)
		if atk>0 and tc:IsAttack(0) then
			-- 触发毒指示物使攻击力降为0导致破坏的自定义事件(EVENT_CUSTOM+54306223)
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end
