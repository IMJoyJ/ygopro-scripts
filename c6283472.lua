--アモルファージ・ヒュペル
-- 效果：
-- ←3 【灵摆】 3→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，双方受到的效果伤害变成0。
-- 【怪兽效果】
-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c6283472.initial_effect(c)
	-- 初始化灵摆怪兽属性
	aux.EnablePendulumAttribute(c)
	-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c6283472.flipop)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c6283472.descon)
	e2:SetOperation(c6283472.desop)
	c:RegisterEffect(e2)
	-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c6283472.sumlimit)
	c:RegisterEffect(e3)
	-- ①：只要自己场上有「无形噬体」怪兽存在，双方受到的效果伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(1,1)
	e4:SetCondition(c6283472.damcon)
	e4:SetValue(c6283472.damval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e5)
end
-- 反转时的操作：为自身注册已反转的标记
function c6283472.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(6283472,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 维持代价的触发条件：自己的准备阶段
function c6283472.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价的效果处理：选择解放怪兽或破坏自身
function c6283472.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在场上对这张卡进行闪烁提示
	Duel.HintSelection(Group.FromCards(c))
	-- 检查是否存在可解放的怪兽并询问玩家是否进行解放
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(6283472,0)) then  --"是否解放自己场上1只怪兽？"
		-- 选出1只用于解放的怪兽
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 解放选中的怪兽
		Duel.Release(g,REASON_MAINTENANCE)
	-- 若不解放怪兽，则将这张卡破坏
	else Duel.Destroy(c,REASON_COST) end
end
-- 限制额外卡组特殊召唤的过滤函数：若自身是灵摆召唤或反转过的，则限制双方不能从额外卡组特殊召唤「无形噬体」以外的怪兽
function c6283472.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
	and (e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) or e:GetHandler():GetFlagEffect(6283472)~=0)
end
-- 过滤条件：表侧表示的「无形噬体」卡
function c6283472.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 效果伤害变0的启用条件：自己场上存在「无形噬体」怪兽
function c6283472.damcon(e)
	-- 检查自己场上是否存在表侧表示的「无形噬体」怪兽
	return Duel.IsExistingMatchingCard(c6283472.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 伤害变化数值函数：将效果伤害变为0
function c6283472.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0 end
	return val
end
