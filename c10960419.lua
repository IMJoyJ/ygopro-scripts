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
-- 设置选择目标的函数
function c10960419.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then return true end
	-- 向玩家提示选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择一个场上正面表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 设置装备效果的处理函数
function c10960419.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsLocation(LOCATION_SZONE) or c:IsFacedown() then return end
	-- 判断是否满足装备条件（场地不足、目标怪兽背面表示或不在场上）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- ②：用这张卡的效果把这张卡装备的怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。掷1次骰子。那只对方怪兽直到和出现的数目相同次数的回合后的准备阶段为止除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c10960419.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 创建在战斗开始时发动的效果
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
-- 设置装备限制条件的函数
function c10960419.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断装备是否有效
function c10960419.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 设置除外与骰子效果的目标函数
function c10960419.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if chk==0 then return tc and tc:IsAbleToRemove() end
	-- 设置操作信息：将目标怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
	-- 设置操作信息：投掷骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 设置除外与骰子效果的处理函数
function c10960419.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 投掷一次骰子
		local ct=Duel.TossDice(tp,1)
		-- 将目标怪兽除外并设置临时除外状态
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			tc:SetTurnCounter(0)
			-- 创建回合计数与返回效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY,ct)
			e1:SetLabel(ct)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetCondition(c10960419.turncon)
			e1:SetOperation(c10960419.turnop)
			-- 注册回合计数效果
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e2:SetCondition(c10960419.retcon)
			e2:SetOperation(c10960419.retop)
			-- 注册返回场上的效果
			Duel.RegisterEffect(e2,tp)
			tc:RegisterFlagEffect(1082946,RESET_PHASE+PHASE_STANDBY,0,ct)
			local mt=_G["c"..tc:GetCode()]
			mt[tc]=e1
		end
	end
end
-- 判断是否处于计数阶段
function c10960419.turncon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffect(1082946)~=0
end
-- 处理回合计数增加
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
-- 判断是否到达返回回合
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
-- 将目标怪兽返回场上
function c10960419.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽返回场上
	Duel.ReturnToField(tc)
end
