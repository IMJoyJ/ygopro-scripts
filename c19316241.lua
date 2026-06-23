--銀河戦竜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是光属性怪兽不能特殊召唤。
-- ①：自己场上有光属性·4星怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：以自己场上1只其他的光属性·4星怪兽为对象才能发动。那只怪兽和这张卡的等级直到回合结束时变成8星。
local s,id,o=GetID()
-- 注册卡片效果和特召限制所需的计数器
function s.initial_effect(c)
	-- 为卡片注册已在墓地标记的检测效果，防止在同一次连锁中重复判定
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
	-- 添加用于检测特殊召唤非光属性怪兽的活动计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：如果是光属性怪兽，则不计入非光属性特殊召唤的计数
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
end
-- 过滤条件：自己场上表侧表示的光属性·4星怪兽，且该怪兽不能是由当前效果触发特殊召唤的
function s.spfilter(c,tp,se)
	return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsFaceup()
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ①效果的发动条件：存在自己场上的光属性·4星怪兽被特殊召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfilter,1,nil,tp,se)
end
-- 效果发动的Cost/限制：本回合自己没有特殊召唤过非光属性怪兽，且发动后本回合自己不能特殊召唤非光属性怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前，确认自己本回合是否特殊召唤过非光属性怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是光属性怪兽不能特殊召唤。①：自己场上有光属性·4星怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制特殊召唤非光属性怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能特殊召唤非光属性的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ①效果的发动准备：检查是否有可用怪兽区域，以及是否可将这张卡特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在特殊召唤前，确认自己是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理：将这张卡特殊召唤，并为其注册离场时除外的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在自身仍与效果关联时，尝试进行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：以自己场上1只其他的光属性·4星怪兽为对象才能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 完成本次特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- ②效果的对象怪兽过滤条件：自己场上表侧表示的光属性·4星怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ②效果的发动准备：选择自己场上1只其他的光属性·4星怪兽为对象
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) and chkc~=c end
	-- 确认自身等级非8且至少为1，且场上存在合规的其他怪兽作为对象
	if chk==0 then return c:IsLevelAbove(1) and not c:IsLevel(8) and Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 向发动效果的玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的光属性·4星怪兽（自身除外）作为对象
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- ②效果的效果处理：使自身与作为对象的怪兽等级直到回合结束变成8星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsLevel(8)
		and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and not tc:IsLevel(8) then
		-- 那只怪兽和这张卡的等级直到回合结束时变成8星。
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
