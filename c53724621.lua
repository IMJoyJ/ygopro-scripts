--EMギタートル
-- 效果：
-- ←6 【灵摆】 6→
-- 「娱乐伙伴 吉他海龟」的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有「娱乐伙伴」卡发动的场合才能发动。自己从卡组抽1张。
-- 【怪兽效果】
-- ①：1回合1次，以自己的灵摆区域1张卡为对象才能发动。那张卡的灵摆刻度直到回合结束时上升2。
function c53724621.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有「娱乐伙伴」卡发动的场合才能发动。自己从卡组抽1张。
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
-- 判断是否满足灵摆效果发动条件：对方发动了灵摆区域的灵摆卡，且该卡为「娱乐伙伴」系列，且不是自身发动的
function c53724621.drcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_PENDULUM) and re:GetHandler():IsSetCard(0x9f) and e:GetHandler()~=re:GetHandler()
end
-- 设置灵摆效果的目标为抽1张卡，检查是否可以发动
function c53724621.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行灵摆效果的抽卡操作
function c53724621.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从卡组抽1张卡，原因来自效果
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 设置怪兽效果的目标为选择自己灵摆区域的1张卡
function c53724621.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) end
	-- 检查玩家是否可以选取灵摆区域的1张卡作为对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标卡为玩家灵摆区域的1张卡
	Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
end
-- 执行怪兽效果，将目标卡的灵摆刻度上升2
function c53724621.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 为选中的灵摆卡添加左刻度上升2的效果，持续到回合结束
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
