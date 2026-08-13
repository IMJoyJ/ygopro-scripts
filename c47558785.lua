--マイルド・ターキー
-- 效果：
-- ←7 【灵摆】 7→
-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子。直到回合结束时，这张卡的灵摆刻度下降出现的数目数值（最少到1）。
-- 【怪兽描述】
-- 对保龄球的热情烤焦全身的狂放火鸡。为了拿到全中而锻炼出来的身体，经常散发出极品的香味。以还没见到的火鸡球作为目标，每天不间断地练习着。
function c47558785.initial_effect(c)
	-- 为温火鸡添加灵摆怪兽的基本属性，使其能够进行灵摆召唤、作为灵摆卡发动并适用灵摆区域相关规则。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子。直到回合结束时，这张卡的灵摆刻度下降出现的数目数值（最少到1）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47558785,0))  --"灵摆刻度下降"
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c47558785.sctg)
	e1:SetOperation(c47558785.scop)
	c:RegisterEffect(e1)
end
-- 该效果的发动条件判定：己方主要阶段且这张卡的当前左灵摆刻度大于1时，才能发动；满足条件后再设置本次连锁的骰子效果操作信息。
function c47558785.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLeftScale()>1 end
	-- 设置操作信息，将本次连锁标记为骰子效果，并预计由发动玩家tp掷1次骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理：若这张卡仍与效果关联且左灵摆刻度大于1，则掷1次骰子，令这张卡的左右灵摆刻度都下降骰子数，但最低下降到1，该变化持续到回合结束时。
function c47558785.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetLeftScale()<=1 then return end
	-- 让玩家tp掷1次骰子，返回点数dc作为后续计算下降数值的依据。
	local dc=Duel.TossDice(tp,1)
	local sch=math.min(c:GetLeftScale()-1,dc)
	-- 直到回合结束时，这张卡的灵摆刻度下降出现的数目数值（最少到1）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(-sch)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
end
