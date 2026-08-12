--ブーテン
-- 效果：
-- 自己的主要阶段时，把墓地存在的这张卡从游戏中除外，选择自己场上表侧表示存在的1只4星以下的天使族·光属性怪兽才能发动。选择的怪兽只要在场上表侧表示存在当作调整使用。
function c83991690.initial_effect(c)
	-- 自己的主要阶段时，把墓地存在的这张卡从游戏中除外，选择自己场上表侧表示存在的1只4星以下的天使族·光属性怪兽才能发动。选择的怪兽只要在场上表侧表示存在当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83991690,0))  --"当成调整使用"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置效果发动的Cost为：将墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c83991690.target)
	e1:SetOperation(c83991690.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的4星以下的天使族·光属性且不是调整的怪兽
function c83991690.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and not c:IsType(TYPE_TUNER)
end
-- 效果发动的靶向处理（Target）：检查并选择自己场上1只符合条件的怪兽作为效果的对象
function c83991690.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c83991690.filter(chkc) end
	-- 检查自己场上是否存在至少1只符合条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c83991690.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c83991690.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理（Operation）：获取选择的对象，若其仍适用，则为其添加“当作调整使用”的效果
function c83991690.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 选择的怪兽只要在场上表侧表示存在当作调整使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
