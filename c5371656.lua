--魂喰らいの魔刀
-- 效果：
-- 这张卡只能装备在自己场上存在的3星以下的通常怪兽身上。这张卡发动时，祭掉自己场上除装备这张卡的怪兽以外的所有通常怪兽（衍生物除外）。每祭掉1只通常怪兽，装备这张卡的怪兽攻击力上升1000点。
function c5371656.initial_effect(c)
	-- 这张卡发动时，祭掉自己场上除装备这张卡的怪兽以外的所有通常怪兽（衍生物除外）。每祭掉1只通常怪兽，装备这张卡的怪兽攻击力上升1000点。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c5371656.target)
	e1:SetOperation(c5371656.operation)
	c:RegisterEffect(e1)
	-- 这张卡只能装备在自己场上存在的3星以下的通常怪兽身上。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c5371656.eqlimit)
	c:RegisterEffect(e2)
end
-- 作为装备限制的判定函数：目标怪兽必须是通常怪兽、等级3以下，且由这张卡的持有者/控制者控制，才能装备这张卡。
function c5371656.eqlimit(e,c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsControler(e:GetHandlerPlayer())
end
-- 过滤出可作为装备对象的怪兽：表侧表示、通常怪兽、等级3以下。
function c5371656.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3)
end
-- 过滤出可作为解放代价的怪兽：是通常怪兽、不是衍生物，并且当前允许被解放。
function c5371656.rfilter(c)
	local tpe=c:GetType()
	return bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0 and c:IsReleasable()
end
-- 装备对象候选的过滤函数：该候选本身满足装备条件，并且自己场上还存在至少1只除它以外的可解放通常怪兽，用于确保发动时能支付解放代价。
function c5371656.tgfilter(c,tp)
	-- 判断场上是否存在至少1只满足解放条件的通常怪兽，且不是当前候选对象；该检查用于保证发动时拥有足够的解放代价。
	return c5371656.filter(c) and Duel.IsExistingMatchingCard(c5371656.rfilter,tp,LOCATION_MZONE,0,1,c)
end
-- 发动时的目标选择与代价处理：选择1只我方场上的3星以下表侧通常怪兽作为装备对象，然后解放场上除该对象以外的所有可解放通常怪兽作为发动代价，将解放数量×1000存入效果标签，并设置装备相关处理信息。
function c5371656.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c5371656.filter(chkc) end
	-- 发动条件检查：我方场上是否存在至少1只能成为装备对象、并且有足够其他怪兽可供解放的通常怪兽。
	if chk==0 then return Duel.IsExistingTarget(c5371656.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 弹出选择提示信息，引导玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 由玩家选择1只满足条件的我方通常怪兽作为装备对象，并将其登记为这张卡的效果对象。
	local g=Duel.SelectTarget(tp,c5371656.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取我方场上除所选装备对象外，所有满足解放条件的通常怪兽（不含衍生物）。
	local rg=Duel.GetMatchingGroup(c5371656.rfilter,tp,LOCATION_MZONE,0,g:GetFirst())
	-- 将这些通常怪兽全部解放，作为这张卡发动的代价。
	Duel.Release(rg,REASON_COST)
	e:SetLabel(rg:GetCount()*1000)
	-- 向系统登记本次效果将进行装备操作，对象为这张卡自身，数量为1，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡和选择的对象仍与效果关联且对象为表侧表示并仍由我方控制，则将这张卡装备给对象，然后创建并注册一个增加攻击力的装备效果，上升值为发动时解放的通常怪兽数量×1000，该效果在装备卡离场等标准重置时机消失。
function c5371656.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将这张卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
		-- 每祭掉1只通常怪兽，装备这张卡的怪兽攻击力上升1000点。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
