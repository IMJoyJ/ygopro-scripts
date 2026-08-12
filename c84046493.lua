--ゴースト・ビーフ
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子。直到回合结束时，这张卡的灵摆刻度上升出现的数目数值（最多到10）。
-- 【怪兽描述】
-- 属于美食家的牛类幽灵。对最爱吃的烤牛肉特别着迷，今天也是为与新味道相遇而一边满怀喜悦一边游荡于现世。
function c84046493.initial_effect(c)
	-- 为卡片注册灵摆怪兽的基本属性，使其可以作为灵摆卡发动及进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子。直到回合结束时，这张卡的灵摆刻度上升出现的数目数值（最多到10）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84046493,0))  --"灵摆刻度上升"
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c84046493.sctg)
	e1:SetOperation(c84046493.scop)
	c:RegisterEffect(e1)
end
-- 灵摆效果的发动准备，检测自身左刻度是否小于10，并声明投骰子的操作信息
function c84046493.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLeftScale()<10 end
	-- 设置在效果处理时需要进行投掷1次骰子的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 灵摆效果的实际处理，投掷骰子并根据结果在回合结束前提升自身的左右灵摆刻度（最高到10）
function c84046493.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetLeftScale()>=10 then return end
	-- 让当前玩家投掷1次骰子，并记录出现的数目
	local dc=Duel.TossDice(tp,1)
	local sch=math.min(10-c:GetLeftScale(),dc)
	-- 直到回合结束时，这张卡的灵摆刻度上升出现的数目数值（最多到10）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(sch)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
end
