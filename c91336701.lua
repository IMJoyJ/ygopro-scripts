--魔導耀士 デイブレイカー
-- 效果：
-- 魔法师族怪兽2只
-- 这个卡名的②④的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合发动。给这张卡放置1个魔力指示物。
-- ②：这张卡所连接区有魔法师族怪兽特殊召唤的场合发动。给这张卡放置1个魔力指示物。
-- ③：这张卡的攻击力上升这张卡的魔力指示物数量×300。
-- ④：把这张卡2个魔力指示物取除，以场上1张卡为对象才能发动。那张卡破坏。
function c91336701.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要2只魔法师族怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_SPELLCASTER),2,2)
	-- ①：这张卡连接召唤的场合发动。给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91336701,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c91336701.ctcon1)
	e1:SetTarget(c91336701.cttg)
	e1:SetOperation(c91336701.ctop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区有魔法师族怪兽特殊召唤的场合发动。给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91336701,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,91336701)
	e2:SetCondition(c91336701.ctcon2)
	e2:SetTarget(c91336701.cttg)
	e2:SetOperation(c91336701.ctop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击力上升这张卡的魔力指示物数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c91336701.atkval)
	c:RegisterEffect(e3)
	-- ④：把这张卡2个魔力指示物取除，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(91336701,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,91336702)
	e4:SetCost(c91336701.descost)
	e4:SetTarget(c91336701.destg)
	e4:SetOperation(c91336701.desop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件判定：此卡是否是通过连接召唤特殊召唤的。
function c91336701.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①和②的发动准备：设置放置魔力指示物的操作信息。
function c91336701.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为放置1个魔力指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果①和②的效果处理：若此卡仍在场，则给此卡放置1个魔力指示物。
function c91336701.ctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 过滤条件：表侧表示、存在于此卡连接区内且是魔法师族的怪兽。
function c91336701.cfilter(c,g)
	return c:IsFaceup() and g:IsContains(c) and c:IsRace(RACE_SPELLCASTER)
end
-- 效果②的发动条件判定：检查特殊召唤的怪兽中是否存在于此卡连接区的表侧表示魔法师族怪兽。
function c91336701.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and eg:IsExists(c91336701.cfilter,1,nil,lg)
end
-- 攻击力上升值的计算函数：返回自身魔力指示物数量乘以300的数值。
function c91336701.atkval(e,c)
	return c:GetCounter(0x1)*300
end
-- 效果④的代价处理：取除自身2个魔力指示物。
function c91336701.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,2,REASON_COST)
end
-- 效果④的发动准备：选择场上1张卡作为对象，并设置破坏的操作信息。
function c91336701.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可作为效果对象的卡片。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果④的效果处理：破坏作为对象的那张卡。
function c91336701.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
