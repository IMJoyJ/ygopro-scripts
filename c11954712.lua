--フライファング
-- 效果：
-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。这张卡给与对方基本分战斗伤害的战斗阶段结束时，这张卡直到下次的自己的准备阶段时从游戏中除外。
local s,id,o=GetID()
-- 为飞牙鲛注册三个效果：战斗伤害时记录标记、贯穿伤害、战斗阶段结束时暂时除外并在下次自己准备阶段返回。
function c11954712.initial_effect(c)
	-- “这张卡给与对方基本分战斗伤害的战斗阶段结束时”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetOperation(c11954712.regop)
	c:RegisterEffect(e1)
	-- “这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- “这张卡给与对方基本分战斗伤害的战斗阶段结束时，这张卡直到下次的自己的准备阶段时从游戏中除外。”
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
-- 当这张卡对对方造成战斗伤害时，给自己注册一个标识（11954712），该标识在战斗阶段结束时重置，用于确认除外效果的条件是否满足。
function c11954712.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(11954712,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 除外效果的发动条件：这张卡持有上述战斗伤害标识（即本战斗阶段已对对方造成过战斗伤害）。
function c11954712.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11954712)~=0
end
-- 除外效果的发动时点：无需选择对象，仅设置将从游戏中除外这张卡的操作信息。
function c11954712.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果处理的信息：将除外这张卡（1张）标记为 CATEGORY_REMOVE，用于连锁/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 除外效果处理：若这张卡仍与效果关联，则将其以‘效果’原因暂时除外；若除外成功且卡片原始卡号仍为本卡，则再注册下次自己准备阶段返回场上的效果。
function c11954712.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 判断除外是否成功（Duel.Remove 返回值非0）以及这张卡是否仍是飞牙鲛（防止被其他卡复制/变身影响），满足时才设置返回效果。
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
			-- “直到下次的自己的准备阶段时从游戏中除外”
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetLabelObject(c)
			e1:SetCondition(c11954712.retcon)
			e1:SetOperation(c11954712.retop)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			-- 将返回效果注册为场上持续效果，使其在下次准备阶段触发。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 返回效果的发动条件：当前回合玩家是本卡的控制者（即自己的准备阶段）。
function c11954712.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者，确保只在‘自己的准备阶段’返回。
	return Duel.GetTurnPlayer()==tp
end
-- 执行返回效果：将暂时除外的这张卡返回场上（以离场前的表示形式）。
function c11954712.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用 Duel.ReturnToField 将 LabelObject 中记录的这张卡返回场上。
	Duel.ReturnToField(e:GetLabelObject())
end
