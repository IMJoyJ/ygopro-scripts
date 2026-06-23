--フライファング
-- 效果：
-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。这张卡给与对方基本分战斗伤害的战斗阶段结束时，这张卡直到下次的自己的准备阶段时从游戏中除外。
local s,id,o=GetID()
-- 创建三个效果：战斗伤害时记录flag、贯穿伤害效果、战斗阶段结束时除外效果
function c11954712.initial_effect(c)
	-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetOperation(c11954712.regop)
	c:RegisterEffect(e1)
	-- 这张卡给与对方基本分战斗伤害
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 这张卡给与对方基本分战斗伤害的战斗阶段结束时，这张卡直到下次的自己的准备阶段时从游戏中除外
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11954712,0))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetCountLimit(1)
	e3:SetCondition(c11954712.rmcon)
	e3:SetTarget(c11954712.rmtg)
	e3:SetOperation(c11954712.rmop)
	c:RegisterEffect(e3)
end
-- 记录flag，用于标记该卡已造成战斗伤害
function c11954712.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(11954712,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 判断是否已造成战斗伤害
function c11954712.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11954712)~=0
end
-- 设置除外效果的目标为自身
function c11954712.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置除外效果的处理信息为除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 执行除外操作并注册返回效果
function c11954712.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 判断是否成功除外且为原卡号
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
			-- 创建一个准备阶段触发的效果，用于将卡返回场上
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetLabelObject(c)
			e1:SetCondition(c11954712.retcon)
			e1:SetOperation(c11954712.retop)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			-- 将效果注册到玩家全局环境
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 返回效果的触发条件：当前回合玩家为效果持有者
function c11954712.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 返回效果的处理函数：将卡返回场上
function c11954712.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将卡以原表示形式返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
