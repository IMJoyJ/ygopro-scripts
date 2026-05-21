--ヨコシマウマ
-- 效果：
-- ←7 【灵摆】 7→
-- ①：这张卡发动的回合的自己主要阶段只有1次，指定没有使用的主要怪兽区域或者魔法与陷阱区域1处才能发动。指定的区域在这张卡在灵摆区域存在期间不能使用。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功的场合，指定没有使用的主要怪兽区域或者魔法与陷阱区域1处才能发动。指定的区域在这只怪兽表侧表示存在期间不能使用。
function c97466438.initial_effect(c)
	-- 注册灵摆怪兽属性，但不自动注册灵摆卡的发动效果。
	aux.EnablePendulumAttribute(c,false)
	-- 这张卡发动的回合
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c97466438.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合，指定没有使用的主要怪兽区域或者魔法与陷阱区域1处才能发动。指定的区域在这只怪兽表侧表示存在期间不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97466438,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetTarget(c97466438.ztg)
	e2:SetOperation(c97466438.zop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ①：这张卡发动的回合的自己主要阶段只有1次，指定没有使用的主要怪兽区域或者魔法与陷阱区域1处才能发动。指定的区域在这张卡在灵摆区域存在期间不能使用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(97466438,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c97466438.zcon)
	e4:SetTarget(c97466438.ztg)
	e4:SetOperation(c97466438.zop)
	c:RegisterEffect(e4)
end
-- 灵摆卡发动时的效果处理：给自身注册一个在回合结束前有效的Flag，用于标记这张卡是在本回合发动的。
function c97466438.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(97466438,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 灵摆效果的发动条件：检查自身是否有本回合发动的Flag。
function c97466438.zcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(97466438)~=0
end
-- 效果发动时的目标选择与合法性检查：确认双方场上是否有可用的主要怪兽区域或魔陷区域。
function c97466438.ztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
		-- 检查对方场上是否有可用的主要怪兽区域。
		+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
		-- 检查自己场上是否有可用的魔法与陷阱区域。
		+Duel.GetLocationCount(tp,LOCATION_SZONE,PLAYER_NONE,0)
		-- 检查对方场上是否有可用的魔法与陷阱区域，并判断上述所有区域中是否至少有1个可用区域。
		+Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>0 end
	-- 让发动效果的玩家选择1个双方场上没有使用的主要怪兽区域或魔法与陷阱区域（排除额外怪兽区域和场地区域）。
	local dis=Duel.SelectDisableField(tp,1,LOCATION_ONFIELD,LOCATION_ONFIELD,0xe000e0)
	e:SetLabel(dis)
	-- 在游戏界面上高亮显示被选择的区域。
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 灵摆效果的效果处理：如果自身仍在灵摆区域，则使选择的区域在自身于灵摆区域存在期间不能使用。
function c97466438.zop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 指定的区域在这张卡在灵摆区域存在期间不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(zone)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 怪兽效果的效果处理：使选择的区域在自身于怪兽区域表侧表示存在期间不能使用。
function c97466438.zop2(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	local c=e:GetHandler()
	-- 指定的区域在这只怪兽表侧表示存在期间不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(zone)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
