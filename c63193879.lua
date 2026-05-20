--セイバー・シャーク
-- 效果：
-- 这张卡不能作为同调素材。自己的主要阶段时，可以选择场上1只鱼族怪兽，从以下效果选择1个发动。这个效果1回合可以使用最多2次。这个效果发动的回合，自己不能把水属性以外的怪兽特殊召唤。
-- ●选择的怪兽的等级上升1星。
-- ●选择的怪兽的等级下降1星。
function c63193879.initial_effect(c)
	-- 自己的主要阶段时，可以选择场上1只鱼族怪兽，从以下效果选择1个发动。这个效果1回合可以使用最多2次。这个效果发动的回合，自己不能把水属性以外的怪兽特殊召唤。●选择的怪兽的等级上升1星。●选择的怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63193879,0))  --"效果发动"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(c63193879.cost)
	e1:SetTarget(c63193879.target)
	e1:SetOperation(c63193879.operation)
	c:RegisterEffect(e1)
	-- 这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于检测玩家特殊召唤非水属性怪兽的行为
	Duel.AddCustomActivityCounter(63193879,ACTIVITY_SPSUMMON,c63193879.counterfilter)
end
-- 过滤函数，用于判定特殊召唤的怪兽是否为水属性
function c63193879.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果发动的Cost，检查本回合是否特殊召唤过非水属性怪兽，并注册本回合不能特殊召唤非水属性怪兽的限制
function c63193879.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在Cost判定阶段，确认本回合至今为止没有特殊召唤过水属性以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(63193879,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不能把水属性以外的怪兽特殊召唤。可以选择场上1只鱼族怪兽，从以下效果选择1个发动。●选择的怪兽的等级上升1星。●选择的怪兽的等级下降1星。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c63193879.splimit)
	-- 给玩家注册不能特殊召唤水属性以外怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽属性不能是水属性以外的属性
function c63193879.splimit(e,c)
	return c:GetAttribute()~=ATTRIBUTE_WATER
end
-- 过滤场上表侧表示且等级大于0的鱼族怪兽
function c63193879.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:GetLevel()>0
end
-- 效果发动的Target，选择场上1只表侧表示的鱼族怪兽为对象，并根据其等级让玩家选择上升或下降1星
function c63193879.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63193879.filter(chkc) end
	-- 判定场上是否存在可以作为对象的表侧表示且等级大于0的鱼族怪兽
	if chk==0 then return Duel.IsExistingTarget(c63193879.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示的鱼族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c63193879.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local op=0
	-- 如果选择的怪兽等级为1，则只能选择“等级上升1星”的选项
	if g:GetFirst():IsLevel(1) then op=Duel.SelectOption(tp,aux.Stringid(63193879,1))  --"等级上升1星"
	-- 如果选择的怪兽等级不为1，则可以让玩家在“等级上升1星”和“等级下降1星”中选择1个
	else op=Duel.SelectOption(tp,aux.Stringid(63193879,1),aux.Stringid(63193879,2)) end  --"等级上升1星/等级下降1星"
	e:SetLabel(op)
end
-- 效果发动的Operation，获取选择的对象怪兽，并根据玩家的选择使其等级上升或下降1星
function c63193879.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- ●选择的怪兽的等级上升1星。●选择的怪兽的等级下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else e1:SetValue(-1) end
		tc:RegisterEffect(e1)
	end
end
