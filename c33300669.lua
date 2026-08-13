--アモルファージ・キャヴム
-- 效果：
-- ←5 【灵摆】 5→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把魔法·陷阱·怪兽的效果连锁发动。
-- 【怪兽效果】
-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c33300669.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽属性（灵摆召唤、灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- 反转过的
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c33300669.flipop)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c33300669.descon)
	e2:SetOperation(c33300669.desop)
	c:RegisterEffect(e2)
	-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c33300669.sumlimit)
	c:RegisterEffect(e3)
	-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把魔法·陷阱·怪兽的效果连锁发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_PZONE)
	e4:SetOperation(c33300669.chainop)
	c:RegisterEffect(e4)
end
-- 当这张卡翻转时，给这张卡注册一个标识，标记其“反转过”，该标识在离场等标准重置条件下清除。
function c33300669.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(33300669,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 筛选具备表侧表示且属于「无形噬体」字段的怪兽，用于判断自己场上是否存在「无形噬体」怪兽。
function c33300669.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 连锁发动时：若自己场上有表侧表示「无形噬体」怪兽，则设置连锁限制，使任何效果都不能连锁发动。
function c33300669.chainop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「无形噬体」怪兽；若不存在则不进行连锁限制，直接返回 false。
	if not Duel.IsExistingMatchingCard(c33300669.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) then return false end
	-- 设置连锁限制条件为恒 false，使双方不能把魔法·陷阱·怪兽的效果连锁发动。
	Duel.SetChainLimit(aux.FALSE)
end
-- 维持代价的触发条件：当前回合玩家是这张卡的控制者，即自己的准备阶段。
function c33300669.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否等于这张卡的控制者，用于确认在准备阶段处理维持代价。
	return Duel.GetTurnPlayer()==tp
end
-- 执行准备阶段的维持代价：展示这张卡；若存在可解放的怪兽且玩家选择“是”，则选1只怪兽解放，否则破坏这张卡。
function c33300669.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 手动为这张卡显示被选中的动画，提示玩家正在处理这张卡的维持代价。
	Duel.HintSelection(Group.FromCards(c))
	-- 检查除自身外是否存在1只可解放的怪兽作为维持代价，并询问玩家是否解放；满足且选择“是”时执行解放。
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(33300669,0)) then  --"是否解放自己场上1只怪兽？"
		-- 让玩家选择1只除这张卡以外可解放的怪兽，用于支付维持代价。
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 将选择的怪兽以“维持代价”的原因解放。
		Duel.Release(g,REASON_MAINTENANCE)
	-- 当无法解放或玩家选择不解放时，以代价原因破坏这张卡（即不解放让这张卡破坏）。
	else Duel.Destroy(c,REASON_COST) end
end
-- 特殊召唤限制判定：当这张卡是灵摆召唤过或翻转过时，来自额外卡组且不属于「无形噬体」的怪兽不能特殊召唤。
function c33300669.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
		and (e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) or e:GetHandler():GetFlagEffect(33300669)~=0)
end
