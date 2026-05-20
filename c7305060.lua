--アモルファージ・プレスト
-- 效果：
-- ←3 【灵摆】 3→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把「无形噬体」卡以外的陷阱卡的效果发动。
-- 【怪兽效果】
-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c7305060.initial_effect(c)
	-- 初始化并注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- 反转过的
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c7305060.flipop)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c7305060.descon)
	e2:SetOperation(c7305060.desop)
	c:RegisterEffect(e2)
	-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c7305060.sumlimit)
	c:RegisterEffect(e3)
	-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把「无形噬体」卡以外的陷阱卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(1,1)
	e4:SetCondition(c7305060.limcon)
	e4:SetValue(c7305060.limval)
	c:RegisterEffect(e4)
end
-- 反转时的操作：给自身注册一个表示已反转过的Flag
function c7305060.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(7305060,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 维持代价效果的发动条件：当前回合是控制者的回合
function c7305060.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价效果的处理：选择解放场上1只怪兽，或者将这张卡破坏
function c7305060.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中这张卡并显示选中动画，提示玩家该卡正在进行维持代价的处理
	Duel.HintSelection(Group.FromCards(c))
	-- 检查自己场上是否存在除这张卡以外可作为维持代价解放的怪兽，并询问玩家是否进行解放
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(7305060,0)) then  --"是否解放自己场上1只怪兽？"
		-- 玩家选择自己场上1只除这张卡以外的怪兽作为解放对象
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 解放选中的怪兽作为维持代价
		Duel.Release(g,REASON_MAINTENANCE)
	-- 若不解放怪兽，则将这张卡因维持代价而破坏
	else Duel.Destroy(c,REASON_COST) end
end
-- 限制特殊召唤的过滤函数：若这张卡是灵摆召唤或反转过的，则双方不能从额外卡组特殊召唤「无形噬体」以外的怪兽
function c7305060.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
		and (e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) or e:GetHandler():GetFlagEffect(7305060)~=0)
end
-- 过滤条件：自己场上表侧表示的「无形噬体」怪兽
function c7305060.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 限制发动效果的条件：自己场上存在「无形噬体」怪兽
function c7305060.limcon(e)
	-- 检查自己场上是否存在表侧表示的「无形噬体」怪兽
	return Duel.IsExistingMatchingCard(c7305060.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 限制发动的效果类型：不能发动「无形噬体」卡以外的陷阱卡的效果
function c7305060.limval(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_TRAP) and not rc:IsSetCard(0xe0)
end
