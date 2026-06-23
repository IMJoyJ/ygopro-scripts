--スカイオニヒトクイエイ
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡进行直接攻击的战斗阶段结束时，这张卡直到下次的自己的准备阶段时从游戏中除外。
local s,id=GetID()
-- 初始化效果函数，创建三个效果：战斗阶段结束时触发的效果、可以直接攻击的效果、以及在战斗阶段结束时除外自己的效果
function c47349310.initial_effect(c)
	-- 当进行直接攻击的战斗阶段结束时，记录一个标志位用于后续判断是否需要除外
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(c47349310.regop)
	c:RegisterEffect(e1)
	-- 使该卡可以进行直接攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 在战斗阶段结束时发动的效果，用于将该卡除外
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47349310,0))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetCountLimit(1)
	e3:SetCondition(c47349310.rmcon)
	e3:SetTarget(c47349310.rmtg)
	e3:SetOperation(c47349310.rmop)
	c:RegisterEffect(e3)
end
-- 战斗阶段结束时触发的函数，用于设置标志位
function c47349310.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果存在攻击对象则不执行后续操作
	if Duel.GetAttackTarget() then return end
	c:RegisterFlagEffect(47349310,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 判断是否满足除外条件，即是否设置了标志位
function c47349310.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(47349310)~=0
end
-- 设置除外效果的目标信息
function c47349310.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置除外效果的操作信息为除外该卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 除外效果的处理函数，将该卡暂时除外并注册返回效果
function c47349310.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 判断是否成功除外且原卡号匹配
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
			-- 创建一个在准备阶段触发的效果，用于将卡返回场上
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetLabelObject(c)
			e1:SetCondition(c47349310.retcon)
			e1:SetOperation(c47349310.retop)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			-- 将创建好的效果注册到玩家全局环境
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 准备阶段触发条件判断函数，判断是否为自己的回合
function c47349310.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段触发的返回函数，将卡返回场上
function c47349310.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将卡以原来的形式返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
