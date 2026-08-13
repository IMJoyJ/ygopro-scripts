--ティスティナの戯れ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地把1只「提斯蒂娜」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
local s,id,o=GetID()
-- 定义卡片效果注册函数s.initial_effect(c)，为卡片c创建并注册其魔法卡发动效果e1：设置效果描述、效果类别为特殊召唤、类型为魔法卡发动、发动时点为自由时点、同名卡1回合1次的誓约次数限制，并指定发动条件和操作函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·墓地把1只「提斯蒂娜」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤的过滤条件s.filter：卡名包含「提斯蒂娜」（字段0x1a4），并且可以被玩家tp以表侧守备表示特殊召唤（不检查召唤条件与苏生限制）。
function s.filter(c,e,tp)
	return c:IsSetCard(0x1a4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义效果发动时的目标检测函数s.target：在发动时检查是否存在可特殊召唤的合法目标（主怪兽区有空位，且手卡·墓地存在1只满足s.filter的「提斯蒂娜」怪兽）；若满足则设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动时点检测（chk==0），首先确认己方主怪兽区是否有空位；若没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 其次检查己方手卡·墓地是否存在至少1只满足s.filter的「提斯蒂娜」怪兽，作为特殊召唤的对象候选。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果类别为特殊召唤，预计从己方手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义效果处理函数s.activate：提示玩家选择要特殊召唤的怪兽，从自己手卡·墓地（过滤王家长眠之谷影响）选择1只，若处理时主怪兽区无空位则中止；若选择成功则通过特殊召唤步骤将其表侧守备表示特殊召唤，并为该怪兽注册结束阶段回手的效果，最后完成特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方手卡·墓地选择1只符合s.filter且不受王家长眠之谷影响的「提斯蒂娜」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 在特殊召唤前再次确认己方主怪兽区仍有空位，避免因处理时场地变化导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若成功选择了怪兽，并且可以将其通过特殊召唤步骤表侧守备表示特殊召唤到己方场上，则继续为其附加结束阶段回手的效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetOperation(s.thop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCountLimit(1)
			tc:RegisterEffect(e1)
	end
	-- 结束特殊召唤步骤，将本阶段通过特殊召唤步骤出场的怪兽正式特殊召唤上场。
	Duel.SpecialSummonComplete()
end
-- 定义结束阶段回手的效果处理函数s.thop：在结束阶段将持有该效果的怪兽送回其持有者的手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果处理时的效果持有者（即被特殊召唤的怪兽）送去其持有者的手卡，原因为效果。
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
