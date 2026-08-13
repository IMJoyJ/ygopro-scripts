--CNo.62 超銀河眼の光子龍皇
-- 效果：
-- 光属性8星怪兽×3
-- 这张卡也能在自己场上的「No.62 银河眼光子龙皇」上面重叠来超量召唤。
-- ①：自己战斗阶段开始时，把这张卡1个超量素材取除才能发动。这张卡在这次战斗阶段中最多3次可以向怪兽攻击。
-- ②：这张卡有「银河眼光子龙」在作为超量素材的场合，得到以下效果。
-- ●这张卡不受对方怪兽的效果影响。
-- ●这张卡的攻击力上升这张卡作为超量素材中的怪兽的等级·阶级的合计×100。
function c48348921.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),8,3,c48348921.ovfilter,aux.Stringid(48348921,1))  --"是否在「No.62 银河眼光子龙皇」上面重叠来超量召唤？"
	-- ①：自己战斗阶段开始时，把这张卡1个超量素材取除才能发动。这张卡在这次战斗阶段中最多3次可以向怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48348921,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c48348921.atkcon)
	e1:SetCost(c48348921.atkcost)
	e1:SetTarget(c48348921.atktg)
	e1:SetOperation(c48348921.atkop)
	c:RegisterEffect(e1)
	-- ●这张卡不受对方怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c48348921.econ)
	e2:SetValue(c48348921.efilter)
	c:RegisterEffect(e2)
	-- ●这张卡的攻击力上升这张卡作为超量素材中的怪兽的等级·阶级的合计×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c48348921.econ)
	e3:SetValue(c48348921.atkval)
	c:RegisterEffect(e3)
end
-- 将该卡登记为编号62的「No.」超量怪兽，用于相关卡片的编号判定。
aux.xyz_number[48348921]=62
-- 定义叠放素材的额外条件：对方（自己场上）需要存在表侧表示的「No.62 银河眼光子龙皇」（卡号31801517），才能在这只怪兽上面重叠来超量召唤。
function c48348921.ovfilter(c)
	return c:IsFaceup() and c:IsCode(31801517)
end
-- ①效果的发动条件判定：当前回合玩家必须是这张卡的控制者，即只有自己战斗阶段开始时才能发动。
function c48348921.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否为这张卡的控制者的回合。
	return Duel.GetTurnPlayer()==tp
end
-- ①效果发动代价：检查并移除这张卡的1个超量素材作为发动代价；若可以支付代价则返回true，并实际移除1张超量素材。
function c48348921.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动目标条件：确认这张卡尚未获得额外攻击怪兽次数的效果，防止重复发动或叠加。
function c48348921.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER)==0 end
end
-- ①效果处理：若这张卡仍与效果关联，则给它注册一个本战斗阶段内“额外攻击怪兽次数+2”的效果，使其合计最多可攻击3次。
function c48348921.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这张卡在这次战斗阶段中最多3次可以向怪兽攻击。（对应的效果处理为赋予额外2次攻击怪兽的机会）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的获得条件判定：这张卡的超量素材中存在「银河眼光子龙」（卡号93717133）时，条件成立。
function c48348921.econ(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,93717133)
end
-- 免疫效果的过滤函数：只免疫对方怪兽发动的效果，即不受对方怪兽的效果影响。
function c48348921.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 攻击力上升数值的设定：取这张卡所有超量素材的等级或阶级合计值，再乘以100作为上升数值。
function c48348921.atkval(e,c)
	return c:GetOverlayGroup():GetSum(c48348921.lv_or_rk)*100
end
-- 计算超量素材的等级或阶级：若素材是超量怪兽则取阶级，否则取等级。
function c48348921.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
