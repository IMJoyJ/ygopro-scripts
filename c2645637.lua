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
	-- 添加连接召唤手续，使用2到4个不死族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2,4)
	-- 只要这张卡在怪兽区域存在，除外的状态发动的对方怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c2645637.disop)
	c:RegisterEffect(e1)
	-- 从墓地有怪兽特殊召唤的场合或者墓地的怪兽的效果发动的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，那个效果无效。
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
-- 使除外状态发动的对方怪兽的效果无效
function c2645637.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否来自除外区且为怪兽卡
	if Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_REMOVED and re:IsActiveType(TYPE_MONSTER) and rp==1-tp then
		-- 使当前连锁效果无效
		Duel.NegateEffect(ev)
	end
end
-- 判断是否为墓地发动的怪兽效果
function c2645637.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否来自墓地且为怪兽卡
	return re:IsActiveType(TYPE_MONSTER) and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE
end
-- 判断怪兽是否从墓地召唤
function c2645637.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE)
end
-- 判断是否为墓地特殊召唤或墓地怪兽效果发动
function c2645637.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2645637.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
		and not (re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
			-- 判断连锁是否来自墓地
			and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE)
end
-- 判断目标怪兽是否表侧表示且攻击力大于0
function c2645637.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 选择目标怪兽并设置操作信息
function c2645637.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c2645637.atkfilter(chkc) and chkc~=c end
	-- 检查是否已使用过效果且场上存在符合条件的目标怪兽
	if chk==0 then return e:GetHandler():GetFlagEffect(2645637)==0 and Duel.IsExistingTarget(c2645637.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	e:GetHandler():RegisterFlagEffect(2645637,RESET_CHAIN,0,1)
	-- 选择场上一只符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c2645637.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置操作信息，表示将使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 处理效果，使目标怪兽攻击力变为0并无效其效果
function c2645637.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 使目标怪兽相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 将目标怪兽的攻击力设为0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 使目标怪兽效果在回合结束时重置
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
