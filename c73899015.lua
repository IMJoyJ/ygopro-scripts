--ヴェノム・スネーク
-- 效果：
-- 1回合只有1次，可以给对方场上1只怪兽放置1个毒指示物。这个效果使用的回合这只怪兽不能攻击宣言。
function c73899015.initial_effect(c)
	-- 1回合只有1次，可以给对方场上1只怪兽放置1个毒指示物。这个效果使用的回合这只怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73899015,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c73899015.cost)
	e1:SetTarget(c73899015.target)
	e1:SetOperation(c73899015.operation)
	c:RegisterEffect(e1)
end
-- 检查自身本回合是否进行过攻击宣言，并为自身施加本回合不能攻击宣言的限制
function c73899015.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果使用的回合这只怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果发动时的目标确认与对象选择，选择对方场上1只可以放置毒指示物的怪兽
function c73899015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1009,1) end
	-- 检查对方场上是否存在可以放置毒指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1009,1) end
	-- 提示玩家选择对方的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只可以放置毒指示物的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1009,1)
	-- 设置效果处理信息为放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 效果处理：给选择的对象怪兽放置1个毒指示物，若其攻击力因此变为0则触发相关事件
function c73899015.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1009,1) then
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,1)
		if atk>0 and tc:IsAttack(0) then
			-- 若怪兽攻击力因放置毒指示物变为0，触发自定义事件（用于处理因毒指示物攻击力归0而破坏的规则）
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end
