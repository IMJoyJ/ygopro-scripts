--擾乱騒蛇ラウドクラウド
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把炎属性和风属性的怪兽各1只除外的场合可以特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1只炎属性怪兽除外，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。这张卡的攻击力上升破坏的怪兽的原本攻击力数值。
-- ②：从自己墓地把1只风属性怪兽除外，以对方的魔法与陷阱区域1张卡为对象才能发动。那张卡破坏。
function c61465001.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把炎属性和风属性的怪兽各1只除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c61465001.spcon)
	e1:SetTarget(c61465001.sptg)
	e1:SetOperation(c61465001.spop)
	c:RegisterEffect(e1)
	-- ①：从自己墓地把1只炎属性怪兽除外，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。这张卡的攻击力上升破坏的怪兽的原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61465001,0))  --"破坏怪兽"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,61465001)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c61465001.descost1)
	e2:SetTarget(c61465001.destg1)
	e2:SetOperation(c61465001.desop1)
	c:RegisterEffect(e2)
	-- ②：从自己墓地把1只风属性怪兽除外，以对方的魔法与陷阱区域1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61465001,1))  --"破坏魔陷"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,61465002)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c61465001.descost2)
	e3:SetTarget(c61465001.destg2)
	e3:SetOperation(c61465001.desop2)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的炎属性或风属性怪兽
function c61465001.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
end
-- 检查卡片组中是否存在1只炎属性怪兽和1只风属性怪兽
function c61465001.cfilter1(c,g)
	return c:IsAttribute(ATTRIBUTE_FIRE) and g:IsExists(Card.IsAttribute,1,c,ATTRIBUTE_WIND)
end
-- 检查选出的卡片组是否满足“炎属性和风属性怪兽各1只”的条件
function c61465001.check(g)
	return g:IsExists(c61465001.cfilter1,1,nil,g)
end
-- 特殊召唤规则的条件函数：检查怪兽区域空位，并确认墓地是否存在满足条件的炎属性和风属性怪兽各1只
function c61465001.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用于特殊召唤怪兽的空余怪兽区域
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中所有可以作为Cost除外的炎属性和风属性怪兽
	local g=Duel.GetMatchingGroup(c61465001.cfilter,tp,LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(c61465001.check,2,2)
end
-- 特殊召唤规则的准备/选择目标函数：从墓地中选择要除外的炎属性和风属性怪兽各1只，并保存在标签对象中
function c61465001.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有可以作为Cost除外的炎属性和风属性怪兽
	local g=Duel.GetMatchingGroup(c61465001.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c61465001.check,true,2,2)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数：将选定的怪兽除外，完成特殊召唤
function c61465001.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽以表侧表示除外，作为特殊召唤的条件
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤自己墓地中可以作为Cost除外的炎属性怪兽
function c61465001.descfilter1(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 效果①的Cost函数：从自己墓地把1只炎属性怪兽除外
function c61465001.descost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以除外的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61465001.descfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c61465001.descfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外，作为发动效果的Cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的目标选择函数：选择对方场上1只怪兽为对象，并设置破坏操作信息
function c61465001.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该连锁将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的执行函数：破坏作为对象的怪兽，并使这张卡的攻击力上升该怪兽的原本攻击力数值
function c61465001.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	local atk=math.max(tc:GetTextAttack(),0)
	if tc:IsRelateToEffect(e) then
		-- 尝试用效果破坏目标怪兽，并检查是否成功破坏
		if Duel.Destroy(tc,REASON_EFFECT)~=0
			and c:IsFaceup() and c:IsRelateToEffect(e) and atk>0 then
			-- 这张卡的攻击力上升破坏的怪兽的原本攻击力数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 过滤自己墓地中可以作为Cost除外的风属性怪兽
function c61465001.descfilter2(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToRemoveAsCost()
end
-- 效果②的Cost函数：从自己墓地把1只风属性怪兽除外
function c61465001.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以除外的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61465001.descfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c61465001.descfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外，作为发动效果的Cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤对方魔法与陷阱区域的卡（排除场地区域，即格子编号小于5的卡）
function c61465001.desfilter(c)
	return c:GetSequence()<5
end
-- 效果②的目标选择函数：选择对方魔法与陷阱区域1张卡为对象，并设置破坏操作信息
function c61465001.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c61465001.desfilter(chkc) end
	-- 检查对方魔法与陷阱区域是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(c61465001.desfilter,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方魔法与陷阱区域的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c61465001.desfilter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置效果处理信息，表示该连锁将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的执行函数：破坏作为对象的魔法·陷阱卡
function c61465001.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 用效果破坏目标魔法·陷阱卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
