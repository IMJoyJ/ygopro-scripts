--フューチャー・グロウ
-- 效果：
-- 把自己墓地存在的1只念动力族怪兽从游戏中除外发动。只要这张卡在场上存在，自己场上表侧表示存在的全部念动力族怪兽的攻击力上升因为这张卡发动而除外的怪兽的等级×200的数值。
function c64107820.initial_effect(c)
	-- 把自己墓地存在的1只念动力族怪兽从游戏中除外发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c64107820.cost)
	e1:SetOperation(c64107820.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上表侧表示存在的全部念动力族怪兽的攻击力上升因为这张卡发动而除外的怪兽的等级×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置攻击力上升效果的影响对象为我方场上的念动力族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PSYCHO))
	e2:SetValue(c64107820.val)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 过滤条件：自己墓地中等级1以上、可以作为发动代价除外的念动力族怪兽
function c64107820.cfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsLevelAbove(1) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：检查并选择自己墓地1只念动力族怪兽除外，计算其等级×200的数值并暂存
function c64107820.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段的检查步骤，确认自己墓地是否存在至少1只满足条件的念动力族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64107820.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给发动玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让发动玩家从自己墓地选择1只满足过滤条件的念动力族怪兽
	local g=Duel.SelectMatchingCard(tp,c64107820.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetLevel()*200)
	e:GetLabelObject():SetLabel(0)
	-- 将选择的怪兽表侧表示除外，作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动时的效果处理：将发动代价中计算好的攻击力上升数值传递给永续效果
function c64107820.operation(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetLabel())
end
-- 攻击力上升的数值：返回保存在效果中的攻击力上升数值（即除外怪兽的等级×200）
function c64107820.val(e,c)
	return e:GetLabel()
end
