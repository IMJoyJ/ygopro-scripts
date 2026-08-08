--零氷の魔妖－雪女
-- 效果：
-- 不死族怪兽2只以上
-- 这个卡名的③的效果1回合可以使用最多2次。
-- ①：「零冰之魔妖-雪女」在自己场上只能有1只表侧表示存在。
-- ②：只要这张卡在怪兽区域存在，除外的状态发动的对方怪兽的效果无效化。
-- ③：从墓地有怪兽特殊召唤的场合或者墓地的怪兽的效果发动的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，那个效果无效。
function c2645637.initial_effect(c)
	c:SetUniqueOnField(1,0,2645637)
	c:EnableReviveLimit()
	-- 执行对应的效果条件检查或辅助函数处理
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2,4)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c2645637.disop)
	c:RegisterEffect(e1)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2645637,0))  --"攻击力变成0"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2,2645637)
	e2:SetCondition(c2645637.atkcon)
	e2:SetTarget(c2645637.atktg)
	e2:SetOperation(c2645637.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c2645637.atkcon2)
	c:RegisterEffect(e3)
end
-- 执行对应的效果条件检查或辅助函数处理
function c2645637.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对应的效果条件检查或辅助函数处理
	if Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_REMOVED and re:IsActiveType(TYPE_MONSTER) and rp==1-tp then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.NegateEffect(ev)
	end
end
-- 执行对应的效果条件检查或辅助函数处理
function c2645637.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对应的效果条件检查或辅助函数处理
	return re:IsActiveType(TYPE_MONSTER) and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE
end
-- 执行对应的效果条件检查或辅助函数处理
function c2645637.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 执行对应的效果条件检查或辅助函数处理
function c2645637.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2645637.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
		and not (re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
			-- 执行对应的效果条件检查或辅助函数处理
			and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE)
end
-- 执行对应的效果条件检查或辅助函数处理
function c2645637.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 执行对应的效果条件检查或辅助函数处理
function c2645637.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c2645637.atkfilter(chkc) and chkc~=c end
	-- 执行对应的效果条件检查或辅助函数处理
	if chk==0 then return e:GetHandler():GetFlagEffect(2645637)==0 and Duel.IsExistingTarget(c2645637.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	e:GetHandler():RegisterFlagEffect(2645637,RESET_CHAIN,0,1)
	-- 执行对应的效果条件检查或辅助函数处理
	local g=Duel.SelectTarget(tp,c2645637.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行对应的效果条件检查或辅助函数处理
function c2645637.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行对应的效果条件检查或辅助函数处理
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 处理卡片效果的发动条件、目标选择及效果操作
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 处理卡片效果的发动条件、目标选择及效果操作
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 处理卡片效果的发动条件、目标选择及效果操作
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
