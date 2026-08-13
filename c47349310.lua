--スカイオニヒトクイエイ
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡进行直接攻击的战斗阶段结束时，这张卡直到下次的自己的准备阶段时从游戏中除外。
local s,id=GetID()
-- 初始化效果：为这张卡注册三个效果：①伤害步骤结束时记录直接攻击的标记；②赋予直接攻击能力；③战斗阶段结束时若本回合直接攻击过则暂时除外自身，并在下次自己的准备阶段返回。
function c47349310.initial_effect(c)
	-- 这张卡进行直接攻击的战斗阶段结束时（此部分用于在伤害步骤结束时检测本次是否为直接攻击并为后续除外做准备）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(c47349310.regop)
	c:RegisterEffect(e1)
	-- 这张卡可以直接攻击对方玩家。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 这张卡进行直接攻击的战斗阶段结束时，这张卡直到下次的自己的准备阶段时从游戏中除外。（该触发效果在战斗阶段结束时若满足直接攻击条件，则将自身暂时除外并设定后续返回。）
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
-- 在伤害步骤结束时，若本次攻击为直接攻击（不存在攻击对象），则给这张卡登记一个标识，用于标记“本回合进行了直接攻击”，该标识在战斗阶段结束时重置。
function c47349310.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果当前伤害步骤存在攻击目标，则说明不是直接攻击，直接返回；否则继续登记直接攻击标记。
	if Duel.GetAttackTarget() then return end
	c:RegisterFlagEffect(47349310,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 除外效果的发动的条件：这张卡持有之前登记的“进行了直接攻击”的标识，即本回合这张卡进行过直接攻击。
function c47349310.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(47349310)~=0
end
-- 除外效果发动时没有取对象，只要满足条件即可发动；同时设置操作信息，将这张卡作为除外处理的对象。
function c47349310.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息：以除外形式处理这张卡1张，用于供其他卡或效果进行响应与检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 除外效果处理时：若这张卡仍与效果关联，则将其以效果且暂时除外的方式除外；若除外成功且原卡号正确，则注册一个在下次自己的准备阶段将这张卡返回场上的效果。
function c47349310.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 尝试将这张卡以效果原因暂时除外，并确认除外成功且原卡号仍为本卡；只有成功被暂时除外才需要设定后续返回效果。
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
			-- 直到下次的自己的准备阶段时从游戏中除外（具体为设定一个在下次自己准备阶段将暂时除外的这张卡返回场上的效果）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetLabelObject(c)
			e1:SetCondition(c47349310.retcon)
			e1:SetOperation(c47349310.retop)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			-- 将该返回效果注册到当前决斗中，使其在下次自己的准备阶段时满足条件即处理返回。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 返回效果的条件：当前回合玩家是效果发动者，即只有“自己的准备阶段”才满足条件。
function c47349310.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果发动玩家，以匹配“自己的准备阶段”这一时机。
	return Duel.GetTurnPlayer()==tp
end
-- 返回效果的处理：将之前被暂时除外的这张卡返回场上。
function c47349310.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果标签中保存的这张卡（之前被暂时除外的那张卡）返回场上。
	Duel.ReturnToField(e:GetLabelObject())
end
