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
	-- 为这张卡注册使用2只以上不死族怪兽作为素材的连接召唤手续。
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
-- 除外状态发动的对方怪兽效果无效的处理函数：检查连锁发生位置是否为除外区且为对方发动的怪兽效果，若是则将其效果无效化。
function c2645637.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁发生位置是否在除外区、是否为怪兽效果且由对方玩家发动。
	if Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_REMOVED and re:IsActiveType(TYPE_MONSTER) and rp==1-tp then
		-- 使该连锁的效果无效化。
		Duel.NegateEffect(ev)
	end
end
-- 墓地怪兽效果发动时诱发攻击力变为0及效果无效的条件检查函数：判断是否为墓地发动的怪兽效果。
function c2645637.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果是否为怪兽效果且连锁发生位置在墓地。
	return re:IsActiveType(TYPE_MONSTER) and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE
end
-- 特殊召唤怪兽过滤函数：检查怪兽是否从墓地特殊召唤且原本类型为怪兽。
function c2645637.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 从墓地有怪兽特殊召唤时诱发效果的条件检查函数：判断是否有怪兽从墓地特殊召唤，且不包含自身及并非由墓地发动的怪兽效果所引发。
function c2645637.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2645637.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
		and not (re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
			-- 判断触发事件连锁发生位置是否在墓地。
			and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE)
end
-- 目标怪兽过滤函数：检查卡片是否在场上表侧表示存在且攻击力大于0。
function c2645637.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 攻击力变为0及无效效果的目标选择函数：检查场上是否存在除自身以外的表侧表示怪兽作为对象，并设置操作信息。
function c2645637.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c2645637.atkfilter(chkc) and chkc~=c end
	-- 检查当前连锁未注册发动标记且场上存在满足条件的除自身以外的表侧表示怪兽作为对象。
	if chk==0 then return e:GetHandler():GetFlagEffect(2645637)==0 and Duel.IsExistingTarget(c2645637.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	e:GetHandler():RegisterFlagEffect(2645637,RESET_CHAIN,0,1)
	-- 选择场上1只除自身以外的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c2645637.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置当前连锁的操作信息为包含1张卡的效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 攻击力变为0及效果无效的处理函数：将作为对象的怪兽攻击力变成0，并使其效果无效化。
function c2645637.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁设定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 使作为对象的怪兽相关连锁的效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的攻击力变成0。
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
