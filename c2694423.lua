--メデューサ・ワーム
-- 效果：
-- 这张卡1个回合1次可以变成里侧守备表示。这张卡反转召唤成功时，对方场上1只怪兽破坏。
function c2694423.initial_effect(c)
	-- 这张卡1个回合1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2694423,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c2694423.target)
	e1:SetOperation(c2694423.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2694423,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c2694423.destg)
	e2:SetOperation(c2694423.desop)
	c:RegisterEffect(e2)
end
-- 起动效果的发动条件：本卡为表侧且可变成里侧守备，并且本回合尚未使用过该效果（flag为0）；满足条件时注册一次使用标记并设置变更表示形式的操作信息。
function c2694423.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(2694423)==0 end
	c:RegisterFlagEffect(2694423,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 将本次效果处理信息设置为改变表示形式，对象为本卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时，若本卡仍与效果关联且为表侧表示，则将其变成里侧守备表示。
function c2694423.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将本卡的表示形式改为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 反转召唤成功时诱发效果的发动条件：选择对方场上1只怪兽作为对象（取对象破坏）。
function c2694423.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 向操作者显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为本效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次效果处理信息设置为破坏，对象为选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，取得对象怪兽，若该怪兽仍与效果关联且当前控制者为对方，则将其破坏。
function c2694423.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中已选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
