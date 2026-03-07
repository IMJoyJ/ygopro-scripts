--ダーク・ネクロフィア
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把3只恶魔族怪兽除外的场合可以特殊召唤。
-- ①：怪兽区域的这张卡被对方破坏送去墓地的回合的结束阶段，以对方场上1只表侧表示怪兽为对象发动。墓地的这张卡当作装备卡使用给那只对方怪兽装备。
-- ②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。
function c31829185.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：怪兽区域的这张卡被对方破坏送去墓地的回合的结束阶段，以对方场上1只表侧表示怪兽为对象发动。墓地的这张卡当作装备卡使用给那只对方怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c31829185.spcon)
	e1:SetTarget(c31829185.sptg)
	e1:SetOperation(c31829185.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c31829185.tgop)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤。从自己墓地把3只恶魔族怪兽除外的场合可以特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c31829185.eqcon)
	e3:SetTarget(c31829185.eqtg)
	e3:SetOperation(c31829185.eqop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的恶魔族怪兽（可除外作为特殊召唤的cost）
function c31829185.spfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件（场上存在空位且墓地有3只恶魔族怪兽）
function c31829185.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断玩家场上是否存在空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家墓地是否存在至少3只恶魔族怪兽
		and Duel.IsExistingMatchingCard(c31829185.spfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 选择并设置要除外的3只恶魔族怪兽
function c31829185.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地所有满足条件的恶魔族怪兽
	local g=Duel.GetMatchingGroup(c31829185.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的3只恶魔族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的除外操作
function c31829185.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的3只恶魔族怪兽从墓地除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 记录该卡被对方破坏送入墓地的标志
function c31829185.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and bit.band(r,REASON_DESTROY)~=0 then
		c:RegisterFlagEffect(31829185,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断该卡是否被对方破坏送入墓地并记录了标志
function c31829185.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(31829185)>0
end
-- 设置装备效果的目标选择和操作信息
function c31829185.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 提示玩家选择要改变控制权的对方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的一只表侧表示怪兽作为装备对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置操作信息：将此卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：此卡离开墓地（装备）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 限制装备卡只能装备给特定怪兽
function c31829185.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备效果并设置控制权变更
function c31829185.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断玩家场上是否存在装备区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备限制效果，防止被其他装备卡装备
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c31829185.eqlimit)
		c:RegisterEffect(e1)
		-- 设置装备卡获得控制权的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		c:RegisterEffect(e2)
	end
end
