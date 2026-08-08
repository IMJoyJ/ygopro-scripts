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
	-- 为卡片添加连接召唤手续：不死族怪兽2只以上（2-4只）
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2,4)
	-- ②：只要这张卡在怪兽区域存在，除外的状态发动的对方怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c2645637.disop)
	c:RegisterEffect(e1)
	-- ③：从墓地有怪兽特殊召唤的场合或者墓地的怪兽的效果发动的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，那个效果无效。
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
-- 除外效果无效化处理：判断触发位置是否为除外区且为对方怪兽效果，若是则将其效果无效化
function c2645637.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁发生位置是否在除外区、是否为怪兽效果且由对方玩家发动
	if Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_REMOVED and re:IsActiveType(TYPE_MONSTER) and rp==1-tp then
		-- 使该连锁的效果无效化
		Duel.NegateEffect(ev)
	end
end
-- 墓地效果发动诱发条件：触发效果为怪兽效果且发生在墓地
function c2645637.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动效果的卡是否为怪兽且发动位置在墓地
	return re:IsActiveType(TYPE_MONSTER) and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE
end
-- 从墓地特召过滤条件：召唤位置为墓地且原本类型为怪兽
function c2645637.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 墓地特召诱发条件：存在从墓地特殊召唤的怪兽且排除自身及重复诱发
function c2645637.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2645637.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
		and not (re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
			-- 检查触发连锁的发动位置是否在墓地（用于避免与墓地发动效果的诱发条件重复）
			and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE)
end
-- 攻击力与效果无效目标过滤条件：表侧表示且攻击力大于0的怪兽
function c2645637.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果发动准备：选择这张卡以外场上1只表侧表示怪兽为对象，设置无效化的操作信息
function c2645637.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c2645637.atkfilter(chkc) and chkc~=c end
	-- 发动条件检查：同一连锁内未发动过且场上存在自身以外满足条件的目标怪兽
	if chk==0 then return e:GetHandler():GetFlagEffect(2645637)==0 and Duel.IsExistingTarget(c2645637.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	e:GetHandler():RegisterFlagEffect(2645637,RESET_CHAIN,0,1)
	-- 选择场上1只自身以外满足条件的表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c2645637.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置连锁操作信息：将目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：将对象怪兽的攻击力变成0，并将其效果无效
function c2645637.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 使对象怪兽当前相关的连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那个效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 那个效果无效。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
