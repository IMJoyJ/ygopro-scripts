--ヴェルズ・サンダーバード
-- 效果：
-- 魔法·陷阱·效果怪兽的效果发动时，可以把自己场上的这张卡从游戏中除外。这个效果在对方回合也能发动。这个效果除外的这张卡在下次的准备阶段时回到场上，攻击力上升300。「入魔雷神鸟」的效果1回合只能发动1次。
function c78663366.initial_effect(c)
	-- 魔法·陷阱·效果怪兽的效果发动时，可以把自己场上的这张卡从游戏中除外。这个效果在对方回合也能发动。这个效果除外的这张卡在下次的准备阶段时回到场上，攻击力上升300。「入魔雷神鸟」的效果1回合只能发动1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetDescription(aux.Stringid(78663366,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,78663366)
	e1:SetTarget(c78663366.target)
	e1:SetOperation(c78663366.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与检测：检查自身是否可以除外，并设置除外操作信息
function c78663366.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置操作信息：将自身作为除外对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身暂时除外，并注册一个在下次准备阶段使自身回到场上且攻击力上升的延迟效果
function c78663366.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关、是否由自己控制，并成功将其以效果原因暂时除外
	if c:IsRelateToEffect(e) and c:IsControler(tp) and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 这个效果除外的这张卡在下次的准备阶段时回到场上，攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		-- 检查当前阶段是否已经是准备阶段
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			-- 将当前回合数记录在效果的Label中
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c78663366.retcon)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		end
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c78663366.retop)
		-- 将延迟效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件：当前回合数不等于效果发动时的回合数
function c78663366.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合数是否不等于记录的回合数
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 延迟效果的处理：将暂时除外的自身返回到场上，若成功且表侧表示存在，则使其攻击力上升300
function c78663366.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 尝试将卡片返回场上，并检查其是否以表侧表示存在
	if Duel.ReturnToField(tc) and tc:IsFaceup() then
		-- 攻击力上升300
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		tc:RegisterEffect(e1)
	end
end
