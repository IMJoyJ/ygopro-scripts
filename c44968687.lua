--伝説のフィッシャーマン三世
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「传说的渔人」解放的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功时才能发动。对方场上的怪兽全部除外。这个回合，这张卡不能攻击。
-- ②：场上的这张卡不会被战斗·效果破坏，不受魔法·陷阱卡的效果影响。
-- ③：1回合1次，自己主要阶段才能发动。除外的对方的卡全部回到墓地，这个回合，对方受到的战斗·效果伤害只有1次变成2倍。
function c44968687.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上1只「传说的渔人」解放的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。把自己场上1只「传说的渔人」解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c44968687.spcon)
	e2:SetTarget(c44968687.sptg)
	e2:SetOperation(c44968687.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功时才能发动。对方场上的怪兽全部除外。这个回合，这张卡不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c44968687.rmtg)
	e3:SetOperation(c44968687.rmop)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡不会被战斗·效果破坏，不受魔法·陷阱卡的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
	-- ②：场上的这张卡不会被战斗·效果破坏，不受魔法·陷阱卡的效果影响。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetValue(c44968687.efilter)
	c:RegisterEffect(e6)
	-- ③：1回合1次，自己主要阶段才能发动。除外的对方的卡全部回到墓地，这个回合，对方受到的战斗·效果伤害只有1次变成2倍。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(c44968687.damtg)
	e7:SetOperation(c44968687.damop)
	c:RegisterEffect(e7)
end
-- 用于判断是否满足特殊召唤条件的过滤函数，检查场上是否有可解放的「传说的渔人」
function c44968687.spfilter(c,tp)
	-- 检查场上是否有可解放的「传说的渔人」且有空怪兽区
	return c:IsCode(3643300) and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足，检查是否有满足条件的可解放卡片
function c44968687.spcon(e,c)
	if c==nil then return true end
	-- 检查是否有满足条件的可解放卡片
	return Duel.CheckReleaseGroupEx(c:GetControler(),c44968687.spfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 设置特殊召唤时的选择目标，选择要解放的卡片
function c44968687.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放的卡片组并筛选出「传说的渔人」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c44968687.spfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c44968687.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的卡片进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 设置效果发动时的目标，检查对方场上是否有怪兽可以除外
function c44968687.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有怪兽可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，指定要除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 执行效果，将对方场上的怪兽除外并使自身不能攻击
function c44968687.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上的怪兽除外
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 使这张卡在本回合不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e:GetHandler():RegisterEffect(e1)
	end
end
-- 效果过滤函数，判断是否为魔法或陷阱卡的效果
function c44968687.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果发动时的目标，检查是否有除外的对方卡片
function c44968687.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有除外的对方卡片
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_REMOVED)>0 end
	-- 获取所有除外的对方卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED)
	-- 设置操作信息，指定要送入墓地的卡片
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 执行效果，将除外的对方卡片送入墓地并使对方受到的伤害翻倍
function c44968687.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有除外的对方卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED)
	-- 将除外的对方卡片送入墓地
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)~=0 then
		-- 设置伤害变化效果，使对方受到的伤害翻倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(c44968687.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册伤害变化效果
		Duel.RegisterEffect(e1,tp)
		-- 注册标识效果，用于记录该效果已发动
		Duel.RegisterFlagEffect(tp,44968687,RESET_PHASE+PHASE_END,0,1)
		-- 设置战斗伤害翻倍效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetValue(DOUBLE_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
		-- 注册战斗伤害翻倍效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 伤害值计算函数，用于判断是否触发伤害翻倍效果
function c44968687.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	-- 判断是否满足伤害翻倍条件
	if Duel.GetFlagEffect(tp,44968687)==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 重置标识效果，防止重复触发
	Duel.ResetFlagEffect(tp,44968687)
	return val*2
end
