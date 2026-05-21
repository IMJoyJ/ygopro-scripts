--パワードクロウラー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。选持有比这张卡低的攻击力的对方场上1只怪兽破坏。
-- ②：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须作出攻击。
function c87742943.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。选持有比这张卡低的攻击力的对方场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87742943,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,87742943)
	e1:SetTarget(c87742943.destg)
	e1:SetOperation(c87742943.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须作出攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e3)
end
-- 过滤条件：对方场上表侧表示且攻击力低于此卡攻击力的怪兽
function c87742943.desfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- ①效果的发动准备：检查对方场上是否存在符合条件的怪兽，并设置破坏的操作信息
function c87742943.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	-- 在发动阶段（chk==0）检查对方场上是否存在至少1只表侧表示且攻击力低于此卡的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87742943.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 设置操作信息：预计破坏对方场上的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
-- ①效果的效果处理：此卡表侧表示存在时，选对方场上1只攻击力低于此卡的怪兽破坏
function c87742943.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=c:GetAttack()
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择对方场上1只表侧表示且攻击力低于此卡的怪兽
		local g=Duel.SelectMatchingCard(tp,c87742943.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
		if g:GetCount()>0 then
			-- 对选中的怪兽进行闪烁提示（确认对象）
			Duel.HintSelection(g)
			-- 将选中的怪兽因效果破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
