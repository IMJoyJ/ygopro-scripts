--アモルファージ・ガストル
-- 效果：
-- ←5 【灵摆】 5→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把「无形噬体」怪兽以外的怪兽的效果发动。
-- 【怪兽效果】
-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c34522216.initial_effect(c)
	-- 启用灵摆怪兽的基础属性，使此卡可作为灵摆卡发动、可进行灵摆召唤，并注册灵摆相关效果。
	aux.EnablePendulumAttribute(c)
	-- 对应“反转过的”：怪兽效果①中限制额外卡组特殊召唤的‘反转过的’条件，这里通过翻转事件为这张卡注册标记，表示已反转。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c34522216.flipop)
	c:RegisterEffect(e1)
	-- ←5 【灵摆】 5→ 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c34522216.descon)
	e2:SetOperation(c34522216.desop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c34522216.sumlimit)
	c:RegisterEffect(e3)
	-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把「无形噬体」怪兽以外的怪兽的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(1,1)
	e4:SetCondition(c34522216.limcon)
	e4:SetValue(c34522216.limval)
	c:RegisterEffect(e4)
end
-- 翻转时给这张卡自身注册一个编号为34522216的标记效果，记录“已反转”状态；该标记会在卡片离场、回手、回卡组、除外的标准重置时清除。
function c34522216.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(34522216,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 过滤函数：判断卡牌是否为表侧表示且属于「无形噬体」系列，用于检查自己场上是否存在符合条件的「无形噬体」怪兽。
function c34522216.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 效果发动条件：自己怪兽区域存在至少1张表侧表示的「无形噬体」怪兽时满足，用于灵摆效果①的发动限制。
function c34522216.limcon(e)
	-- 以效果控制者视角，在自己怪兽区域检索是否存在至少1张满足cfilter条件（表侧表示且为「无形噬体」）的卡牌。
	return Duel.IsExistingMatchingCard(c34522216.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 定义受限效果的范围：发动效果的类型为怪兽效果，且该效果持有者不是「无形噬体」怪兽时，该效果不能发动。
function c34522216.limval(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsSetCard(0xe0)
end
-- 维持效果触发条件：当前回合玩家是这张卡的控制者，即只在控制者的准备阶段执行维持处理。
function c34522216.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否等于效果控制者，避免在对方准备阶段错误触发维持解放效果。
	return Duel.GetTurnPlayer()==tp
end
-- 处理准备阶段的维持代价：将这张卡作为提示对象，询问控制者是否解放自己场上1只怪兽；若选择是则解放，否则破坏这张卡。
function c34522216.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 手动显示这张卡被选为对象的动画，并记录其成为对象，用于维持代价的提示展示。
	Duel.HintSelection(Group.FromCards(c))
	-- 检查控制者场上是否存在除这张卡以外的可解放怪兽，并弹出“是否解放自己场上1只怪兽？”的确认选择；选择是则进入解放分支，否则进入破坏分支。
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(34522216,0)) then  --"是否解放自己场上1只怪兽？"
		-- 让控制者从自己场上选择1只可解放的怪兽（不包括这张卡），作为维持代价要解放的对象。
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 将选中的怪兽解放，并设置解放原因为维持代价（REASON_MAINTENANCE）。
		Duel.Release(g,REASON_MAINTENANCE)
	-- 若没有可解放怪兽或玩家选择“否”，则将这张卡破坏，破坏原因设为代价（REASON_COST），表示无法支付维持代价而被破坏。
	else Duel.Destroy(c,REASON_COST) end
end
-- 限制额外卡组特殊召唤：当这张卡是灵摆召唤过或已反转过的状态时，所特殊召唤的怪兽必须来自额外卡组且属于「无形噬体」系列，否则不能特殊召唤。
function c34522216.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
		and (e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) or e:GetHandler():GetFlagEffect(34522216)~=0)
end
