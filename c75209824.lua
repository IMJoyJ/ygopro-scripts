--ガーディアン・スタチュー
-- 效果：
-- 这张卡1个回合1次可以变成里侧守备表示。这张卡反转召唤成功时，对方场上1只怪兽回到持有者的手卡。
function c75209824.initial_effect(c)
	-- 这张卡1个回合1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75209824,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c75209824.target)
	e1:SetOperation(c75209824.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，对方场上1只怪兽回到持有者的手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75209824,1))  --"返回手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c75209824.thtg)
	e2:SetOperation(c75209824.thop)
	c:RegisterEffect(e2)
end
-- 检查自身是否可以变成里侧守备表示且本回合未发动过该效果，注册回合内只能发动一次的标记，并设置改变表示形式的操作信息
function c75209824.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(75209824)==0 end
	c:RegisterFlagEffect(75209824,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置当前连锁的操作信息为将1张自身卡片改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 若自身仍在场上且呈表侧表示，则将其转为里侧守备表示
function c75209824.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身卡片改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 反转召唤成功时发动效果的靶向处理，选择对方场上1只可以回到手牌的怪兽作为对象，并设置送回手牌的操作信息
function c75209824.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只可以回到手牌的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 获取选中的对象，若对象仍存在且在对方场上，则将其送回持有者的手牌
function c75209824.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 通过效果将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
