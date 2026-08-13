--伝説のフィッシャーマン三世
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「传说的渔人」解放的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功时才能发动。对方场上的怪兽全部除外。这个回合，这张卡不能攻击。
-- ②：场上的这张卡不会被战斗·效果破坏，不受魔法·陷阱卡的效果影响。
-- ③：1回合1次，自己主要阶段才能发动。除外的对方的卡全部回到墓地，这个回合，对方受到的战斗·效果伤害只有1次变成2倍。
function c44968687.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上1只「传说的渔人」解放的场合才能特殊召唤。
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
	-- ②：场上的这张卡不会被战斗·效果破坏。
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
	-- 不受魔法·陷阱卡的效果影响。
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
-- 过滤函数：解放对象必须是「传说的渔人」，且解放后我方场上有空余怪兽区可供特殊召唤。
function c44968687.spfilter(c,tp)
	-- 判断卡片是否满足解放条件：卡号为3643300（「传说的渔人」）且解放后场上仍有可用怪兽区。
	return c:IsCode(3643300) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤条件：确认控制者场上存在至少1只可解放的「传说的渔人」，且满足解放后可特殊召唤的条件。
function c44968687.spcon(e,c)
	if c==nil then return true end
	-- 检查控制者是否拥有满足条件的可解放「传说的渔人」作为特殊召唤的解放源。
	return Duel.CheckReleaseGroupEx(c:GetControler(),c44968687.spfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 特殊召唤选择处理：从可解放的卡中筛选出符合条件的「传说的渔人」，由玩家选择1张，并将选中的卡保存到效果标签中。
function c44968687.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放的卡组并过滤出符合条件的「传说的渔人」作为候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c44968687.spfilter,nil,tp)
	-- 显示选择提示信息，要求玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤操作：解放步骤所选的「传说的渔人」，完成规则特殊召唤。
function c44968687.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的「传说的渔人」解放，作为这次特殊召唤的代价。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①的发动条件与对象设定：确认对方场上有可除外的怪兽，并将对方场上全部可除外的怪兽设定为除外对象。
function c44968687.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：对方场上是否存在至少1只可以除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上全部可以除外的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：本次处理将除外对方场上全部可除外的怪兽，数量为组内卡数。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- ①效果处理：将对方场上全部怪兽表侧表示除外；若确有除外，给自身附加本回合不能攻击的效果。
function c44968687.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上全部可以除外的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 实际执行除外：将对方场上可除外的怪兽全部表侧表示除外；若除外数量不为0则继续。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 这个回合，这张卡不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e:GetHandler():RegisterEffect(e1)
	end
end
-- 免疫过滤器：只有发动者为魔法或陷阱卡的效果才会被免疫，怪兽效果不免疫。
function c44968687.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- ③的发动条件与对象设定：确认对方除外区有卡，并将对方除外的全部卡设定为送回墓地的对象。
function c44968687.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：对方除外区是否存在至少1张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_REMOVED)>0 end
	-- 获取对方除外区的全部卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED)
	-- 设置操作信息：本次处理将对方除外的全部卡送去墓地，数量为组内卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ③效果处理：将对方除外的全部卡送回墓地；若成功，给对手附加本回合下一次战斗·效果伤害翻倍的效果。
function c44968687.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取对方除外区的全部卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED)
	-- 将对方除外的全部卡以归还理由送去墓地；若实际送入数量不为0则继续。
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)~=0 then
		-- 这个回合，对方受到的战斗·效果伤害只有1次变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(c44968687.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 给对方玩家注册效果伤害变化效果，使对方在本回合受到的效果伤害按damval逻辑计算。
		Duel.RegisterEffect(e1,tp)
		-- 登记标识，记录效果伤害翻倍机会已可使用，用于damval判断是否只翻倍一次。
		Duel.RegisterFlagEffect(tp,44968687,RESET_PHASE+PHASE_END,0,1)
		-- 这个回合，对方受到的战斗·效果伤害只有1次变成2倍。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetValue(DOUBLE_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
		-- 给对方玩家注册战斗伤害变化效果，使对方本回合受到的战斗伤害变为2倍。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 伤害变化回调：若效果伤害翻倍机会尚未使用且本次伤害为效果伤害，则伤害翻倍并消耗机会；否则返回原伤害。
function c44968687.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	-- 判断是否应该翻倍：机会标记已消失或本次不是效果伤害时，不翻倍。
	if Duel.GetFlagEffect(tp,44968687)==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 清除机会标记，保证效果伤害翻倍只适用一次。
	Duel.ResetFlagEffect(tp,44968687)
	return val*2
end
