--ドラグニティ－レギオン
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只龙族·3星以下的「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：把自己的魔法与陷阱区域1张表侧表示的「龙骑兵团」卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏。
function c54578613.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只龙族·3星以下的「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54578613,0))  --"装备"
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c54578613.eqtg)
	e1:SetOperation(c54578613.eqop)
	c:RegisterEffect(e1)
	-- ②：把自己的魔法与陷阱区域1张表侧表示的「龙骑兵团」卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54578613,1))  --"对方场上表侧表示存在的1只怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c54578613.descost)
	e2:SetTarget(c54578613.destg)
	e2:SetOperation(c54578613.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中等级3以下的龙族「龙骑兵团」怪兽，且不能是无法放置在魔陷区的卡
function c54578613.filter(c)
	return c:IsSetCard(0x29) and c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 效果①的靶向/发动条件判定与目标选择
function c54578613.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c54578613.filter(chkc) end
	-- 发动条件判定：检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件判定：检查自己墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingTarget(c54578613.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54578613.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果①的效果处理：将目标怪兽作为装备卡装备给这张卡
function c54578613.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只龙族怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c54578613.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制：该装备卡只能装备给这张卡
function c54578613.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤条件：自己魔陷区表侧表示的「龙骑兵团」卡，且能作为cost送去墓地
function c54578613.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsAbleToGraveAsCost()
end
-- 效果②的发动代价处理：将自己魔陷区1张表侧表示的「龙骑兵团」卡送去墓地
function c54578613.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价判定：检查自己魔陷区是否存在至少1张满足条件的表侧表示「龙骑兵团」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c54578613.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择自己魔陷区1张表侧表示的「龙骑兵团」卡
	local g=Duel.SelectMatchingCard(tp,c54578613.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：表侧表示的怪兽
function c54578613.desfilter(c)
	return c:IsFaceup()
end
-- 效果②的靶向/发动条件判定与目标选择
function c54578613.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c54578613.desfilter(chkc) end
	-- 发动条件判定：检查对方场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c54578613.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54578613.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：破坏作为对象的对方场上的表侧表示怪兽
function c54578613.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
