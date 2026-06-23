--アモルファージ・ガストル
-- 效果：
-- ←5 【灵摆】 5→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把「无形噬体」怪兽以外的怪兽的效果发动。
-- 【怪兽效果】
-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c34522216.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把「无形噬体」怪兽以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c34522216.flipop)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c34522216.descon)
	e2:SetOperation(c34522216.desop)
	c:RegisterEffect(e2)
	-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
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
-- 在翻转时为该卡注册一个标记，用于后续判断是否为灵摆召唤或反转召唤
function c34522216.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(34522216,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 过滤函数：检查场上是否存在「无形噬体」怪兽（正面表示）
function c34522216.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 条件函数：判断是否己方场上存在「无形噬体」怪兽
function c34522216.limcon(e)
	-- 检查己方场上是否存在至少1只「无形噬体」怪兽
	return Duel.IsExistingMatchingCard(c34522216.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 值函数：判断是否为怪兽效果且该效果的发动者不是「无形噬体」怪兽
function c34522216.limval(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsSetCard(0xe0)
end
-- 条件函数：判断是否为己方的准备阶段
function c34522216.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段处理函数：提示选择该卡为对象，并询问是否解放场上1只怪兽，否则破坏该卡
function c34522216.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为该卡显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 检查己方是否可以解放1只怪兽，并询问是否选择解放
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(34522216,0)) then  --"是否解放自己场上1只怪兽？"
		-- 选择1只可解放的怪兽作为目标
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 将目标怪兽解放
		Duel.Release(g,REASON_MAINTENANCE)
	-- 若不选择解放，则将该卡破坏
	else Duel.Destroy(c,REASON_COST) end
end
-- 限制条件函数：判断是否为从额外卡组特殊召唤且不是「无形噬体」怪兽，且该卡为灵摆召唤或反转召唤
function c34522216.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
		and (e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) or e:GetHandler():GetFlagEffect(34522216)~=0)
end
