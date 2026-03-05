--銀河戦竜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是光属性怪兽不能特殊召唤。
-- ①：自己场上有光属性·4星怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：以自己场上1只其他的光属性·4星怪兽为对象才能发动。那只怪兽和这张卡的等级直到回合结束时变成8星。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①特殊召唤效果和②等级变更效果
function s.initial_effect(c)
	-- 注册一个监听卡片进入墓地的单次持续效果，用于判断是否从墓地发动效果
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：自己场上有光属性·4星怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetLabelObject(e0)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只其他的光属性·4星怪兽为对象才能发动。那只怪兽和这张卡的等级直到回合结束时变成8星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"等级变成8"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.cost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于记录玩家在本回合中进行的特殊召唤次数，限制每回合只能发动一次
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，仅对光属性怪兽进行计数
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 特殊召唤条件过滤函数，用于判断是否满足特殊召唤的条件
function s.spfilter(c,tp,se)
	return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsFaceup()
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 特殊召唤发动条件函数，判断是否有光属性4星怪兽被特殊召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfilter,1,nil,tp,se)
end
-- 效果发动时的费用函数，检查是否为本回合第一次发动特殊召唤效果，若不是则不能发动
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为本回合第一次发动特殊召唤效果
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 设置不能特殊召唤非光属性怪兽的效果，用于限制发动后的召唤限制
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将费用效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的函数，禁止非光属性怪兽特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 特殊召唤目标设定函数，检查是否可以特殊召唤该卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，告知连锁处理中将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤执行函数，将该卡特殊召唤到场上并设置其离开场上的处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否可以被特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置该卡从场上离开时被移除的处理，防止其被送入墓地
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 等级变更目标过滤函数，用于筛选符合条件的光属性4星怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 等级变更目标设定函数，选择目标怪兽并设置等级变更效果
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) and chkc~=c end
	-- 检查是否满足等级变更的条件
	if chk==0 then return c:IsLevelAbove(1) and not c:IsLevel(8) and Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 等级变更执行函数，将目标怪兽和自身等级变为8星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsLevel(8)
		and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and not tc:IsLevel(8) then
		-- 设置等级变更效果，将目标怪兽等级变为8星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
end
