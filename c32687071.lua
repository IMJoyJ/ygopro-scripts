--アモルファージ・ノーテス
-- 效果：
-- ←3 【灵摆】 3→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能用抽卡以外的方法从卡组把卡加入手卡。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c32687071.initial_effect(c)
	-- 为这张卡注册灵摆怪兽的基础属性（灵摆召唤、灵摆区域的发动等），使其成为正式的灵摆怪兽。
	aux.EnablePendulumAttribute(c)
	-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c32687071.descon)
	e1:SetOperation(c32687071.desop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】①：只要这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c32687071.sumlimit)
	c:RegisterEffect(e2)
	-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能用抽卡以外的方法从卡组把卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_HAND)
	e3:SetRange(LOCATION_PZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetCondition(c32687071.limcon)
	-- 将效果的适用对象限定为位于卡组的卡，从而仅禁止“从卡组加入手卡”的非抽卡行为。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e3)
end
-- 维持效果e1的触发条件：仅在当前回合玩家是这张卡的控制者时，准备阶段事件才会触发维持代价处理（对应“自己准备阶段”）。
function c32687071.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果控制者，确保只在自己的准备阶段处理维持代价。
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价的操作：展示此卡，若控制者存在可解放的怪兽且选择“是”，则选择并解放1只怪兽作为维持代价；否则破坏这张卡。
function c32687071.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 手动显示这张卡被选为处理对象的动画并记录其为对象，提示玩家此卡即将进行维持处理。
	Duel.HintSelection(Group.FromCards(c))
	-- 检查控制者是否拥有可解放的怪兽（排除此卡），并询问玩家是否解放1只怪兽来维持这张灵摆卡；成立时进入解放分支。
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(32687071,0)) then  --"是否解放自己场上1只怪兽？"
		-- 让控制者以维持代价为目的选择1只可解放的怪兽（排除这张卡自身）作为即将解放的对象。
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 以维持代价（REASON_MAINTENANCE）解放所选择的怪兽，完成“把自己场上1只怪兽解放”的支付。
		Duel.Release(g,REASON_MAINTENANCE)
	-- 若玩家选择不解放或没有可解放的怪兽，则以代价原因（REASON_COST）破坏这张卡，对应“或者不解放让这张卡破坏”。
	else Duel.Destroy(c,REASON_COST) end
end
-- 额外卡组特殊召唤限制的判定：从额外卡组发起的特殊召唤，若召唤对象不是「无形噬体」怪兽，则不允许；双方玩家均受限。
function c32687071.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
end
-- 过滤函数：判断一张卡是否为表侧表示且属于「无形噬体」系列，用于检查场上是否存在适用限制条件的怪兽。
function c32687071.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 灵摆效果①的限制条件：只要自己场上有表侧表示的「无形噬体」怪兽存在，该限制效果即生效。
function c32687071.limcon(e)
	-- 检索自己场上怪兽区是否存在至少1张表侧表示的「无形噬体」怪兽，作为限制效果是否适用的判定结果。
	return Duel.IsExistingMatchingCard(c32687071.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
