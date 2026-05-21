--紫炎の荒武者
-- 效果：
-- 这张卡召唤成功时，给这张卡放置1个武士道指示物（最多1个）。这张卡有武士道指示物放置的场合，这张卡的攻击力上升300。此外，1回合1次，可以把这张卡放置的武士道指示物取除，并选择场上表侧表示存在的1张可以放置武士道指示物的卡放置1个武士道指示物。
function c98162021.initial_effect(c)
	c:EnableCounterPermit(0x3)
	c:SetCounterLimit(0x3,1)
	-- 这张卡召唤成功时，给这张卡放置1个武士道指示物（最多1个）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98162021,0))  --"放置武士道指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c98162021.addct)
	e1:SetOperation(c98162021.addc)
	c:RegisterEffect(e1)
	-- 这张卡有武士道指示物放置的场合，这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c98162021.attackup)
	c:RegisterEffect(e2)
	-- 此外，1回合1次，可以把这张卡放置的武士道指示物取除，并选择场上表侧表示存在的1张可以放置武士道指示物的卡放置1个武士道指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98162021,0))  --"放置武士道指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c98162021.addct2)
	e3:SetOperation(c98162021.addc2)
	c:RegisterEffect(e3)
end
c98162021.counter_add_list={0x3}
-- 召唤成功时放置指示物效果的发动准备与操作信息设置
function c98162021.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果的处理为在场上放置1个武士道指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x3)
end
-- 召唤成功时放置指示物效果的处理：若自身仍在场，则给自身放置1个武士道指示物
function c98162021.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x3,1)
	end
end
-- 攻击力上升值计算：每个武士道指示物使攻击力上升300点
function c98162021.attackup(e,c)
	return c:GetCounter(0x3)*300
end
-- 移去自身指示物并给场上其他卡放置指示物效果的发动条件与目标选择判定
function c98162021.addct2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsCanAddCounter(0x3,1) end
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x3,1,REASON_EFFECT)
		-- 判定场上是否存在除自身以外、可以放置武士道指示物的卡片
		and Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),0x3,1) end
	-- 提示玩家选择要放置指示物的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择场上1张可以放置武士道指示物的卡作为效果的对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),0x3,1)
end
-- 移去自身指示物并给目标卡片放置指示物效果的处理：移去自身1个武士道指示物，并给选择的表侧表示对象卡片放置1个武士道指示物
function c98162021.addc2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCounter(0x3)==0 then return end
	c:RemoveCounter(tp,0x3,1,REASON_EFFECT)
	-- 获取在发动时选择的作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x3,1)
	end
end
