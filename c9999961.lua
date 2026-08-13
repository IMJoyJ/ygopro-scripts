--ビーストレイジ
-- 效果：
-- 自己场上存在的全部怪兽的攻击力上升从游戏中除外的自己的兽族以及鸟兽族怪兽数量×200的数值。
function c9999961.initial_effect(c)
	-- 自己场上存在的全部怪兽的攻击力上升从游戏中除外的自己的兽族以及鸟兽族怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9999961.target)
	e1:SetOperation(c9999961.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：卡片为表侧表示且种族为兽族或鸟兽族，用于统计除外区满足条件的怪兽。
function c9999961.rfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_WINDBEAST)
end
-- 效果发动时的合法性检测：检查自己场上是否存在表侧表示怪兽，且除外区是否存在满足‘表侧表示且兽族/鸟兽族’条件的自己的怪兽。
function c9999961.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在至少1张表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查自己除外区是否存在至少1张满足‘表侧表示且兽族/鸟兽族’条件的怪兽。
		and Duel.IsExistingMatchingCard(c9999961.rfilter,tp,LOCATION_REMOVED,0,1,nil) end
end
-- 效果处理：获取自己场上全部表侧表示怪兽，计算除外区满足条件的兽族/鸟兽族怪兽数量×200作为攻击力上升值；若场上无怪兽或上升值为0则直接返回；否则给每只表侧表示怪兽赋予攻击力上升效果。
function c9999961.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示怪兽，作为攻击力上升的适用对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 统计除外区中满足‘表侧表示且兽族/鸟兽族’条件的自己的怪兽数量，乘以200得到攻击力上升值。
	local atk=Duel.GetMatchingGroupCount(c9999961.rfilter,tp,LOCATION_REMOVED,0,nil)*200
	if g:GetCount()==0 or atk==0 then return end
	local tc=g:GetFirst()
	while tc do
		-- 攻击力上升从游戏中除外的自己的兽族以及鸟兽族怪兽数量×200的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
