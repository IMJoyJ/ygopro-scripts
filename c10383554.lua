--デストーイ・ホイールソウ・ライオ
-- 效果：
-- 「锋利小鬼·锯子」＋「毛绒动物」怪兽
-- 这张卡不用融合召唤不能特殊召唤。「魔玩具·轮锯狮」的效果1回合只能使用1次，这个效果发动的回合，这张卡不能直接攻击。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，给与对方破坏的怪兽的原本攻击力数值的伤害。
function c10383554.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤的手续，以「锋利小鬼·锯子」和1只「毛绒动物」怪兽为融合素材
	aux.AddFusionProcCodeFun(c,34688023,aux.FilterBoolFunction(Card.IsFusionSetCard,0xa9),1,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置只能通过融合召唤特殊召唤的限制
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 「魔玩具·轮锯狮」的效果1回合只能使用1次，这个效果发动的回合，这张卡不能直接攻击。①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，给与对方破坏的怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,10383554)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c10383554.cost)
	e2:SetTarget(c10383554.target)
	e2:SetOperation(c10383554.operation)
	c:RegisterEffect(e2)
end
-- 效果发动的誓约与成本检测，检查此卡本回合是否进行过直接攻击，并注册此卡本回合不能直接攻击的效果
function c10383554.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsDirectAttacked() end
	-- 这个效果发动的回合，这张卡不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤表侧表示的怪兽
function c10383554.filter(c)
	return c:IsFaceup()
end
-- 以对方场上1只表侧表示怪兽为对象发动，并设置破坏和伤害的操作信息
function c10383554.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c10383554.filter(chkc) end
	-- 检查对方场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c10383554.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择需要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10383554.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	-- 设置破坏作为对象怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置给与对方相当于所选怪兽原本攻击力数值伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 破坏作为对象的怪兽，并给与对方该怪兽原本攻击力数值的伤害
function c10383554.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取已选择的作为效果对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 以效果破坏作为对象的怪兽，并检查是否成功破坏
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方相当于被破坏怪兽原本攻击力数值的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
