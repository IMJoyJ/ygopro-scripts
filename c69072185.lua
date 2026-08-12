--アモルファージ・イリテュム
-- 效果：
-- ←5 【灵摆】 5→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，「无形噬体」卡以外的被送去双方墓地的卡不去墓地而除外。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c69072185.initial_effect(c)
	-- 初始化灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c69072185.descon)
	e1:SetOperation(c69072185.desop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c69072185.sumlimit)
	c:RegisterEffect(e2)
	-- ①：只要自己场上有「无形噬体」怪兽存在，「无形噬体」卡以外的被送去双方墓地的卡不去墓地而除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c69072185.rmcon)
	e3:SetTarget(c69072185.rmtarget)
	e3:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
-- 维持代价效果的发动条件：自己回合的准备阶段
function c69072185.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价效果的处理：选择解放1只怪兽或者破坏此卡
function c69072185.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示此卡被选为效果处理对象的动画
	Duel.HintSelection(Group.FromCards(c))
	-- 检查自己场上是否有除此卡以外可解放的怪兽，并询问玩家是否进行解放
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(69072185,0)) then  --"是否解放自己场上1只怪兽？"
		-- 选择自己场上1只除此卡以外的可解放怪兽
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 解放选中的怪兽作为维持代价
		Duel.Release(g,REASON_MAINTENANCE)
	-- 若不解放怪兽，则将此卡因无法支付维持代价而破坏
	else Duel.Destroy(c,REASON_COST) end
end
-- 限制特召的过滤函数：限制从额外卡组特殊召唤非「无形噬体」怪兽
function c69072185.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
end
-- 过滤条件：场上表侧表示的「无形噬体」怪兽
function c69072185.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 除外效果的适用条件：自己场上存在「无形噬体」怪兽
function c69072185.rmcon(e)
	-- 检查自己场上是否存在表侧表示的「无形噬体」怪兽
	return Duel.IsExistingMatchingCard(c69072185.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 除外效果的对象过滤：非「无形噬体」卡片
function c69072185.rmtarget(e,c)
	return not c:IsSetCard(0xe0)
end
