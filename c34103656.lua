--忘却の都 レミューリア
-- 效果：
-- 这张卡的卡名当作「海」使用。只要这张卡在场上存在，场上的水属性怪兽的攻击力·守备力上升200。此外，1回合1次，自己的主要阶段时才能发动。只要这张卡在场上存在，自己场上的水属性怪兽的等级直到结束阶段时上升和自己场上的水属性怪兽数量相同数值。
function c34103656.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，场上的水属性怪兽的攻击力·守备力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	-- 设置该永续效果的对象筛选条件：只有水属性怪兽能作为攻击力上升的适用对象。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 此外，1回合1次，自己的主要阶段时才能发动。只要这张卡在场上存在，自己场上的水属性怪兽的等级直到结束阶段时上升和自己场上的水属性怪兽数量相同数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34103656,0))  --"等级上升"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c34103656.lvtg)
	e4:SetOperation(c34103656.lvop)
	c:RegisterEffect(e4)
end
-- 辅助过滤函数：判断怪兽是否为表侧表示、水属性且等级大于0，供发动条件的检查使用。
function c34103656.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:GetLevel()>0
end
-- 起动效果的发动条件判定函数：确认己方场上有满足条件的怪兽时才可发动。
function c34103656.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查己方怪兽区是否存在至少1只满足 cfilter 条件的表侧水属性怪兽（等级大于0），作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c34103656.cfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤函数：统计己方场上表侧表示的水属性怪兽（不限等级）的数量，用于计算等级上升的数值。
function c34103656.lvfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果处理：若场地卡仍与效果关联，则统计当前己方场上表侧水属性怪兽数量作为上升值，并取得己方场上最后出场的怪兽的FieldID作为标记，随后给场地卡注册一个持续到结束阶段的等级提升效果，只对发动时已在场上的水属性怪兽生效。
function c34103656.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 统计己方场上表侧表示的水属性怪兽数量，作为本次等级提升的幅度。
		local lv=Duel.GetMatchingGroupCount(c34103656.lvfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取己方场上全部怪兽的集合，用于进一步求取其中 FieldID 的最大值作为限制标记。
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		local mg,fid=g:GetMaxGroup(Card.GetFieldID)
		-- 只要这张卡在场上存在，自己场上的水属性怪兽的等级直到结束阶段时上升和自己场上的水属性怪兽数量相同数值。
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
-- 等级上升效果的适用对象判定：只对 FieldID 不大于保存标记、水属性且等级大于0的怪兽生效，即只影响效果处理时已经在场的怪兽，之后新出场的怪兽不适用。
function c34103656.efftg(e,c)
	return c:GetFieldID()<=e:GetLabel() and c:IsAttribute(ATTRIBUTE_WATER) and c:GetLevel()>0
end
