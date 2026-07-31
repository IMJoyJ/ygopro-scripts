--雲魔物－アルトス
-- 效果：
-- 这张卡不会被战斗破坏。这张卡表侧守备表示在场上存在的场合，这张卡破坏。这张卡的召唤成功时，给这张卡放置场上存在的名字带有「云魔物」的怪兽数量的雾指示物。可以把场上存在的雾指示物取除3个，对方手卡随机丢弃1张。
function c79703905.initial_effect(c)
	-- 永续效果：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 规则效果：这张卡表侧守备表示在场上存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c79703905.sdcon)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功的场合发动。给这张卡放置场上存在的「云魔物」怪兽数量的雾指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79703905,0))  --"放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c79703905.addc)
	c:RegisterEffect(e3)
	-- ②：把场上3个雾指示物去除才能发动。对方手牌随机选1张丢弃。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79703905,1))  --"丢弃手牌"
	e4:SetCategory(CATEGORY_HANDES_OPPO)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c79703905.hdcost)
	e4:SetTarget(c79703905.hdtg)
	e4:SetOperation(c79703905.hdop)
	c:RegisterEffect(e4)
end
c79703905.mentioned_counter={
	[0x1019]=true,
}
-- 自毁条件：自身在场上处于表侧守备表示
function c79703905.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 计数过滤条件：场上表侧表示的「云魔物」怪兽
function c79703905.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
-- 放置指示物效果处理：根据场上表侧表示「云魔物」怪兽数量，给自身放置雾指示物
function c79703905.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 获取全场表侧表示「云魔物」怪兽的总数量
		local ct=Duel.GetMatchingGroupCount(c79703905.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		e:GetHandler():AddCounter(0x1019,ct)
	end
end
-- ②效果发动Cost：去除场上3个雾指示物
function c79703905.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：判断场上是否存在至少3个可去除的雾指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1019,3,REASON_COST) end
	-- 从场上去除3个雾指示物
	Duel.RemoveCounter(tp,1,1,0x1019,3,REASON_COST)
end
-- ②效果发动准备：检查对方手牌数，设置丢弃手牌操作信息
function c79703905.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方手牌数不为0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 end
	-- 设置连锁操作信息：对方丢弃手牌1张
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- ②效果处理：随机选择对方1张手牌送去墓地
function c79703905.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 从对方手牌中随机选择1张
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
	-- 将选中的手牌因效果舍弃送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
end
