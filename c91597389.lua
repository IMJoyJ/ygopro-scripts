--ゲットライド！
-- 效果：
-- 选择自己墓地存在的1只同盟怪兽，给自己场上表侧表示存在的可以装备的怪兽装备。
function c91597389.initial_effect(c)
	-- 选择自己墓地存在的1只同盟怪兽，给自己场上表侧表示存在的可以装备的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c91597389.target)
	e1:SetOperation(c91597389.operation)
	c:RegisterEffect(e1)
end
c91597389.has_text_type=TYPE_UNION
-- 过滤自己墓地中可以作为同盟装备的同盟怪兽的条件函数
function c91597389.filter(c,tp)
	-- 检查卡片是否为同盟怪兽，且自己场上是否存在至少1只可以装备该同盟怪兽的表侧表示怪兽
	return c:IsType(TYPE_UNION) and Duel.IsExistingMatchingCard(c91597389.filter2,tp,LOCATION_MZONE,0,1,nil,c)
end
-- 过滤自己场上可以装备指定同盟怪兽的表侧表示怪兽的条件函数
function c91597389.filter2(c,eqc)
	-- 检查怪兽是否表侧表示，且该同盟怪兽是否可以装备在它身上，并满足同盟装备的规则检查
	return c:IsFaceup() and eqc:CheckUnionTarget(c) and aux.CheckUnionEquip(eqc,c)
end
-- 效果发动时的目标选择与合法性检查函数
function c91597389.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c91597389.filter(chkc,tp) end
	-- 在发动效果时，检查自己魔陷区是否有足够的空位（考虑当前发动的魔法卡占用的格子）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>(e:GetHandler():IsLocation(LOCATION_SZONE) and 0 or 1)
		-- 并检查自己墓地是否存在可以作为效果对象的同盟怪兽
		and Duel.IsExistingTarget(c91597389.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地存在的1只同盟怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c91597389.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置效果处理信息为“有1张卡离开墓地”
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理的执行函数
function c91597389.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的同盟怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查该同盟怪兽是否仍对效果有效，且自己魔陷区仍有空位
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择场上表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择自己场上1只可以装备该同盟怪兽的表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,c91597389.filter2,tp,LOCATION_MZONE,0,1,1,nil,tc)
		local tc2=g:GetFirst()
		-- 如果存在合法的装备对象，且满足同盟装备规则，则将该同盟怪兽作为装备卡装备给目标怪兽
		if tc2 and aux.CheckUnionEquip(tc,tc2) and Duel.Equip(tp,tc,tc2) then
			-- 为装备的同盟怪兽添加同盟状态属性
			aux.SetUnionState(tc)
		end
	end
end
