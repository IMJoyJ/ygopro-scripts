--タイムマジック・ハンマー
-- 效果：
-- 这张卡在用「赫谟之爪」的效果把自己的手卡·场上的魔法师族怪兽送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。掷1次骰子。那只对方怪兽直到和出现的数目相同次数的回合后的准备阶段为止除外。
function c10960419.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡在用「赫谟之爪」的效果把自己的手卡·场上的魔法师族怪兽送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c10960419.eqtg)
	e2:SetOperation(c10960419.eqop)
	c:RegisterEffect(e2)
end
c10960419.material_race=RACE_SPELLCASTER
-- ①效果的发动时点：选择这张卡以外的场上1只表侧表示怪兽作为装备对象；若是连锁处理前检查对象，则验证对象位于主要怪兽区、表侧表示且不是这张卡自身。
function c10960419.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then return true end
	-- 弹出选择提示，告知玩家“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方主要怪兽区选择1张表侧表示怪兽作为装备对象，且不能选择这张卡自身，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 特殊召唤成功后的①效果处理：把这张卡当作装备卡装备给对象怪兽；装备成功后为这张卡附加装备限制，并在其作为装备卡存在时注册②的掷骰子除外效果。
function c10960419.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的装备对象怪兽；若没有对象则直接结束处理。
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsLocation(LOCATION_SZONE) or c:IsFacedown() then return end
	-- 判断装备是否还能进行：自己魔陷区没有空位、对象变成里侧表示或对象已与本次效果失去关联，满足任一条件则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备失败时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡成功装备到对象怪兽上。
	Duel.Equip(tp,c,tc)
	-- 这张卡当作装备卡使用给那只怪兽装备（装备对象限制为发动时选择的那只怪兽）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c10960419.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- ②：用这张卡的效果把这张卡装备的怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。掷1次骰子。那只对方怪兽直到和出现的数目相同次数的回合后的准备阶段为止除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c10960419.rmcon)
	e2:SetTarget(c10960419.rmtg)
	e2:SetOperation(c10960419.rmop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制条件：只有当初选择的那只对象怪兽才能装备这张卡。
function c10960419.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果的触发条件：这张卡装备着的怪兽正在与对方怪兽进行战斗，即进入伤害步骤开始时。
function c10960419.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- ②效果的发动判定：取得装备怪兽的战斗对象；若那只对方怪兽存在且可以被除外，则允许发动，并登记除外与掷骰子的操作信息。
function c10960419.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if chk==0 then return tc and tc:IsAbleToRemove() end
	-- 登记操作信息：预定要除外的卡是战斗对象的那只对方怪兽，数量为1，供其他卡牌或效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
	-- 登记操作信息：本效果包含掷1次骰子，供骰子相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- ②效果的结算：掷1次骰子，按骰子数决定除外持续时间；若对方怪兽仍与战斗相关，则将其暂时除外，并注册后续经过对应数量的准备阶段后返回场上的效果。
function c10960419.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 掷1次骰子，得到的数字ct用于决定对方怪兽被除外直到经过多少个回合后的准备阶段。
		local ct=Duel.TossDice(tp,1)
		-- 将战斗对象的那只对方怪兽以暂时除外的方式除外；若除外成功，才继续设置回合计数与返回处理。
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			tc:SetTurnCounter(0)
			-- 那只对方怪兽直到和出现的数目相同次数的回合后的准备阶段为止除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY,ct)
			e1:SetLabel(ct)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetCondition(c10960419.turncon)
			e1:SetOperation(c10960419.turnop)
			-- 注册第1个持续效果：在抽卡阶段开始时累计回合数，用于计算除外已经经过的回合。
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e2:SetCondition(c10960419.retcon)
			e2:SetOperation(c10960419.retop)
			-- 注册第2个持续效果：在准备阶段检查累计回合数是否达到骰子数，达到则执行返回处理。
			Duel.RegisterEffect(e2,tp)
			tc:RegisterFlagEffect(1082946,RESET_PHASE+PHASE_STANDBY,0,ct)
			local mt=_G["c"..tc:GetCode()]
			mt[tc]=e1
		end
	end
end
-- 计数效果的条件：被除外的怪兽仍带有计数标志，说明它尚未经过足够的回合。
function c10960419.turncon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffect(1082946)~=0
end
-- 计数效果处理：每经过一个回合的抽卡阶段，将对象的回合计数器加1；当计数超过骰子数时，清除标志并重置该计数效果。
function c10960419.turnop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local ct=tc:GetTurnCounter()
	ct=ct+1
	tc:SetTurnCounter(ct)
	if ct>e:GetLabel() then
		tc:ResetFlagEffect(1082946)
		e:Reset()
	end
end
-- 返回效果的条件：计数器等于骰子数时，在准备阶段允许返回；若计数已超过则重置计数效果并阻止重复返回。
function c10960419.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local ct=tc:GetTurnCounter()
	if ct==e:GetLabel() then
		return true
	end
	if ct>e:GetLabel() then
		e:Reset()
	end
	return false
end
-- 返回效果处理：取出被临时除外的对象怪兽，准备将其返回场上。
function c10960419.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将被临时除外的对象怪兽返回场上（默认以离场前的表示形式）。
	Duel.ReturnToField(tc)
end
