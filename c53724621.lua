--EMギタートル
-- 效果：
-- ←6 【灵摆】 6→
-- 「娱乐伙伴 吉他海龟」的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有「娱乐伙伴」卡发动的场合才能发动。自己从卡组抽1张。
-- 【怪兽效果】
-- ①：1回合1次，以自己的灵摆区域1张卡为对象才能发动。那张卡的灵摆刻度直到回合结束时上升2。
function c53724621.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽属性（灵摆召唤、灵摆卡发动等基础处理）。
	aux.EnablePendulumAttribute(c)
	-- 「娱乐伙伴 吉他海龟」的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域有「娱乐伙伴」卡发动的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,53724621)
	e2:SetCondition(c53724621.drcon)
	e2:SetTarget(c53724621.drtg)
	e2:SetOperation(c53724621.drop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以自己的灵摆区域1张卡为对象才能发动。那张卡的灵摆刻度直到回合结束时上升2。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c53724621.target)
	e3:SetOperation(c53724621.operation)
	c:RegisterEffect(e3)
end
-- 灵摆效果发动条件：己方发动了「娱乐伙伴」灵摆卡且该卡不是这张卡自身时才满足条件。
function c53724621.drcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_PENDULUM) and re:GetHandler():IsSetCard(0x9f) and e:GetHandler()~=re:GetHandler()
end
-- 灵摆效果的发动判定：检查能否抽卡，并登记本次连锁为抽卡效果。
function c53724621.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查己方是否可以抽1张卡（如不受“不能抽卡”类效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次处理信息登记为“抽1张卡”，供其他卡进行效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时实际进行的操作：让己方抽1张卡。
function c53724621.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因让己方从卡组抽1张卡，完成抽卡处理。
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 怪兽效果的取对象选择：选择己方灵摆区域的1张卡作为对象。
function c53724621.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) end
	-- 检查己方灵摆区域是否存在至少1张可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil) end
	-- 向玩家显示“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从己方灵摆区域选择1张卡，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
end
-- 效果处理：如果对象仍与效果关联，则令其灵摆刻度左右各上升2，直到回合结束时有效。
function c53724621.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- “那张卡的灵摆刻度直到回合结束时上升2。”
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		tc:RegisterEffect(e2)
	end
end
