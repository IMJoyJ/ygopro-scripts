--メンタル・チューナー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●把光·暗属性怪兽各最多1只从自己的手卡·墓地除外才能发动。直到回合结束时这张卡的等级上升或者下降除外数量的数值。
-- ●以除外的自己的光·暗属性怪兽各最多1只为对象才能发动。那些怪兽回到墓地，直到回合结束时这张卡的等级上升或者下降回去数量的数值。
local s,id,o=GetID()
-- 创建1个永续起动效果，限制1回合1次使用，效果选择1个发动
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvtg)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手卡或墓地的光·暗属性怪兽是否可以除外
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsAbleToRemoveAsCost()
end
-- 过滤函数，用于判断除外区的光·暗属性怪兽是否可以送去墓地
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsFaceup() and c:IsAbleToGrave()
end
-- 效果处理函数，根据玩家选择决定发动哪种效果，一是除外手卡·墓地的怪兽，二是回收除外的怪兽
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 检查手卡或墓地是否存在至少1只光·暗属性怪兽
	local b1=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
	-- 检查除外区是否存在至少1只光·暗属性怪兽
	local b2=Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 玩家选择发动效果1（除外手卡·墓地的怪兽）或效果2（回收除外的怪兽）
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))  --"除外手卡·墓地的怪兽/回收除外的怪兽"
	elseif b1 then
		-- 玩家选择发动效果1（除外手卡·墓地的怪兽）
		op=Duel.SelectOption(tp,aux.Stringid(id,0))  --"除外手卡·墓地的怪兽"
	else
		-- 玩家选择发动效果2（回收除外的怪兽）
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1  --"回收除外的怪兽"
	end
	if op==0 then
		e:SetProperty(0)
		e:SetCategory(0)
		-- 获取手卡或墓地所有光·暗属性怪兽
		local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从候选卡组中选择1~2张属性不同的怪兽
		local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,2)
		-- 将选中的怪兽除外
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
		e:SetLabel(#sg)
		e:SetOperation(s.lvop1)
	else
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 获取除外区所有光·暗属性怪兽
		local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从候选卡组中选择1~2张属性不同的怪兽
		local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,2)
		-- 设置效果对象为选中的怪兽
		Duel.SetTargetCard(sg)
		e:SetOperation(s.lvop2)
		-- 设置连锁操作信息为送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	end
end
-- 效果1的处理函数，根据除外数量调整自身等级
function s.lvop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local lv=e:GetLabel()
	local op=0
	if c:IsLevelBelow(lv) then
		-- 玩家选择等级上升
		op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"等级上升"
	else
		-- 玩家选择等级上升或下降
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"等级上升/等级下降"
	end
	-- 直到回合结束时这张卡的等级上升或者下降除外数量的数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	if op==0 then
		e1:SetValue(lv)
	else
		e1:SetValue(-lv)
	end
	c:RegisterEffect(e1)
end
-- 效果2的处理函数，根据回收数量调整自身等级
function s.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中与效果相关的对象
	local g=Duel.GetTargetsRelateToChain()
	-- 将对象怪兽送去墓地
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)>0
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 计算实际送去墓地的怪兽数量
		local lv=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		local op=0
		if c:IsLevelBelow(lv) then
			-- 玩家选择等级上升
			op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"等级上升"
		else
			-- 玩家选择等级上升或下降
			op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"等级上升/等级下降"
		end
		-- 直到回合结束时这张卡的等级上升或者下降回去数量的数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		if op==0 then
			e1:SetValue(lv)
		else
			e1:SetValue(-lv)
		end
		c:RegisterEffect(e1)
	end
end
