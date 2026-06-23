--アモルファージ・キャヴム
-- 效果：
-- ←5 【灵摆】 5→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能把魔法·陷阱·怪兽的效果连锁发动。
-- 【怪兽效果】
-- ①：只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c33300669.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- 只要自己场上有「无形噬体」怪兽存在，双方不能把魔法·陷阱·怪兽的效果连锁发动。
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
	-- 只要灵摆召唤·反转过的这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
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
-- 记录该卡被翻转时的标志位，用于后续判断是否为灵摆召唤或反转召唤
function c33300669.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(33300669,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 过滤函数，用于判断场上是否存在「无形噬体」怪兽
function c33300669.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 当有效果发动时，若场上存在「无形噬体」怪兽则禁止所有连锁
function c33300669.chainop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「无形噬体」怪兽，若无则不执行连锁限制
	if not Duel.IsExistingMatchingCard(c33300669.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) then return false end
	-- 设置连锁限制条件为始终返回假值，从而禁止所有连锁
	Duel.SetChainLimit(aux.FALSE)
end
-- 判断当前回合玩家是否为该卡控制者
function c33300669.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡控制者
	return Duel.GetTurnPlayer()==tp
end
-- 在准备阶段时，提示玩家选择是否解放场上怪兽或破坏该卡
function c33300669.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示该卡被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 检查玩家是否可以解放场上怪兽并询问玩家是否选择解放
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(33300669,0)) then  --"是否解放自己场上1只怪兽？"
		-- 让玩家从场上或手卡选择1张可解放的卡
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 将选中的卡解放
		Duel.Release(g,REASON_MAINTENANCE)
	-- 若玩家不选择解放，则破坏该卡
	else Duel.Destroy(c,REASON_COST) end
end
-- 限制从额外卡组特殊召唤非「无形噬体」怪兽的效果
function c33300669.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
		and (e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) or e:GetHandler():GetFlagEffect(33300669)~=0)
end
