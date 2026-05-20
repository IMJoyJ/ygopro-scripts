--アモルファージ・ルクス
-- 效果：
-- ←5 【灵摆】 5→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把「无形噬体」卡以外的魔法卡的效果发动。
-- 【怪兽效果】
-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c70917315.initial_effect(c)
	-- 初始化灵摆怪兽属性（注册灵摆召唤、灵摆卡的发动等效果）
	aux.EnablePendulumAttribute(c)
	-- 反转过的
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c70917315.flipop)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c70917315.descon)
	e2:SetOperation(c70917315.desop)
	c:RegisterEffect(e2)
	-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c70917315.sumlimit)
	c:RegisterEffect(e3)
	-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把「无形噬体」卡以外的魔法卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(1,1)
	e4:SetCondition(c70917315.limcon)
	e4:SetValue(c70917315.limval)
	c:RegisterEffect(e4)
end
-- 反转时的操作：给自身注册Flag，用于记录该卡曾反转过
function c70917315.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(70917315,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 过滤条件：表侧表示的「无形噬体」卡
function c70917315.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 限制发动效果的条件：自己场上存在「无形噬体」怪兽
function c70917315.limcon(e)
	-- 检查自己场上是否存在表侧表示的「无形噬体」怪兽
	return Duel.IsExistingMatchingCard(c70917315.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 限制发动的效果：非「无形噬体」卡的魔法卡的效果
function c70917315.limval(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_SPELL) and not rc:IsSetCard(0xe0)
end
-- 维持代价的触发条件：当前回合是控制者的回合（自己准备阶段）
function c70917315.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价的执行：选择解放1只怪兽或者破坏这张卡
function c70917315.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示这张卡被选为效果对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 检查自己场上是否有可解放的怪兽，并询问玩家是否选择解放
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(70917315,0)) then  --"是否解放自己场上1只怪兽？"
		-- 让玩家选择自己场上1只怪兽作为解放的怪兽
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 解放选中的怪兽作为维持代价
		Duel.Release(g,REASON_MAINTENANCE)
	-- 否则（不解放怪兽），将这张卡破坏
	else Duel.Destroy(c,REASON_COST) end
end
-- 限制特殊召唤的过滤函数：若自身是灵摆召唤或反转过的，则双方不能从额外卡组特殊召唤「无形噬体」以外的怪兽
function c70917315.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
		and (e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) or e:GetHandler():GetFlagEffect(70917315)~=0)
end
