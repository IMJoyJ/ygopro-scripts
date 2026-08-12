--アームド・ドラゴン・サンダー LV10
-- 效果：
-- ①：「武装龙」怪兽的效果特殊召唤的这张卡得到自身的攻击力的以下效果。
-- ●1以上：卡名当作「武装龙 LV10」使用。
-- ●10以上：这个控制权不能变更。
-- ●100以上：不会被战斗破坏。
-- ●1000以上：对方回合1次，把1张手卡送去墓地，以场上1张其他卡为对象才能发动。那张卡破坏，自身的攻击力上升1000。
-- ●10000以上：1回合1次，可以发动。场上的其他卡全部破坏。
function c58153103.initial_effect(c)
	-- ①：「武装龙」怪兽的效果特殊召唤的这张卡得到自身的攻击力的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c58153103.regcon)
	e1:SetOperation(c58153103.regop)
	c:RegisterEffect(e1)
end
c58153103.lvup={59464593}
c58153103.lvdn={94141712,21546416,57030525}
-- 检查特殊召唤该卡的效果是否为「武装龙」怪兽的效果
function c58153103.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x111)
end
-- 为这张卡注册根据自身攻击力获得对应效果的5个效果
function c58153103.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 注册在怪兽区域卡名当作「武装龙 LV10」使用的效果
	local e1=aux.EnableChangeCode(c,59464593,LOCATION_MZONE,c58153103.condition)
	e1:SetLabel(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e2:SetLabel(10)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	e3:SetLabel(100)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	-- ●1000以上：对方回合1次，把1张手卡送去墓地，以场上1张其他卡为对象才能发动。那张卡破坏，自身的攻击力上升1000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(58153103,0))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1)
	e4:SetLabel(1000)
	e4:SetCondition(c58153103.condition)
	e4:SetCost(c58153103.descost)
	e4:SetTarget(c58153103.destg)
	e4:SetOperation(c58153103.desop)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e4)
	-- ●10000以上：1回合1次，可以发动。场上的其他卡全部破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(58153103,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetLabel(10000)
	e5:SetCondition(c58153103.condition)
	e5:SetTarget(c58153103.destg2)
	e5:SetOperation(c58153103.desop2)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e5)
end
-- 检查自身攻击力是否在指定数值以上，且对于1000以上的效果还需满足是对方回合
function c58153103.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 自身攻击力在Label值以上，且若Label为1000则必须在对方回合
	return e:GetHandler():IsAttackAbove(e:GetLabel()) and (e:GetLabel()~=1000 or Duel.GetTurnPlayer()==1-tp)
end
-- 1000以上效果的发动代价：将1张手卡送去墓地
function c58153103.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡作为代价送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 1000以上效果的发动准备：选择场上1张其他卡作为对象，并设置破坏效果分类
function c58153103.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 检查场上是否存在除自身以外的其他卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要破坏的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张除自身以外的卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置效果处理信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 1000以上效果的处理：破坏对象卡，若成功破坏则自身攻击力上升1000
function c58153103.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关，则将其破坏；破坏成功且自身仍在场上表侧表示存在时，进行后续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 自身的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 10000以上效果的发动准备：检查场上是否存在其他卡，并设置破坏效果分类
function c58153103.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在除自身以外的其他卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除自身以外的所有其他卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置效果处理信息为破坏场上所有的其他卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 10000以上效果的处理：破坏场上除自身以外的所有其他卡
function c58153103.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除自身以外的所有其他卡（排除自身）
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 破坏获取到的所有其他卡
	Duel.Destroy(g,REASON_EFFECT)
end
