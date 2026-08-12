--忘却の都 レミューリア
-- 效果：
-- 这张卡的卡名当作「海」使用。只要这张卡在场上存在，场上的水属性怪兽的攻击力·守备力上升200。此外，1回合1次，自己的主要阶段时才能发动。只要这张卡在场上存在，自己场上的水属性怪兽的等级直到结束阶段时上升和自己场上的水属性怪兽数量相同数值。
function c34103656.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 永续效果：场上的水属性怪兽的攻击力上升200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	-- 设置效果目标为水属性怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 起动效果：1回合1次，自己的主要阶段时才能发动。只要这张卡在场上存在，自己场上的水属性怪兽的等级直到结束阶段时上升和自己场上的水属性怪兽数量相同数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34103656,0))  --"等级上升"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c34103656.lvtg)
	e4:SetOperation(c34103656.lvop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查场上是否存在满足条件的水属性怪兽
function c34103656.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:GetLevel()>0
end
-- 效果的条件判断：检查场上是否存在至少1只水属性怪兽
function c34103656.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34103656.cfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤函数：检查场上水属性怪兽（无等级限制）
function c34103656.lvfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果执行函数：计算场上水属性怪兽数量并为它们增加等级
function c34103656.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 计算场上水属性怪兽数量
		local lv=Duel.GetMatchingGroupCount(c34103656.lvfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取场上所有怪兽的卡片组
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		local mg,fid=g:GetMaxGroup(Card.GetFieldID)
		-- 创建一个用于提升等级的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetRange(LOCATION_FZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c34103656.efftg)
		e1:SetValue(lv)
		e1:SetLabel(fid)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 效果目标函数：根据FieldID判断是否为当前处理的怪兽并满足水属性条件
function c34103656.efftg(e,c)
	return c:GetFieldID()<=e:GetLabel() and c:IsAttribute(ATTRIBUTE_WATER) and c:GetLevel()>0
end
