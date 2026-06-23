--機装天使エンジネル
-- 效果：
-- 3星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择自己场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成表侧守备表示，这个回合那只怪兽不会被战斗以及卡的效果破坏。这个效果在对方回合也能发动。
function c15914410.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为3的怪兽叠放2只以上，最多2只
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择自己场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成表侧守备表示，这个回合那只怪兽不会被战斗以及卡的效果破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15914410,0))  --"破坏耐性"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c15914410.poscost)
	e1:SetTarget(c15914410.postg)
	e1:SetOperation(c15914410.posop)
	c:RegisterEffect(e1)
end
-- 支付效果代价，从自己场上把1个超量素材取除
function c15914410.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选条件：自己场上表侧攻击表示存在的怪兽
function c15914410.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 选择目标：自己场上表侧攻击表示存在的1只怪兽
function c15914410.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c15914410.filter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c15914410.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择表侧攻击表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择1只表侧攻击表示的怪兽作为效果对象
	Duel.SelectTarget(tp,c15914410.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：将选择的怪兽变为表侧守备表示，并赋予其不会被战斗以及卡的效果破坏的效果
function c15914410.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		-- 这个回合那只怪兽不会被战斗以及卡的效果破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
