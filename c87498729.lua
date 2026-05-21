--ティスティナの落とし仔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地才能发动。从卡组把1张「神域 巴普-提斯蒂娜」在自己的场地区域表侧表示放置。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「提斯蒂娜」魔法·陷阱卡被对方的效果破坏的场合，把这张卡除外才能发动。从自己的手卡·卡组·墓地把1只光属性「提斯蒂娜」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册该卡片的效果①和效果②。
function s.initial_effect(c)
	-- 在卡片中记录关联卡名「神域 巴普-提斯蒂娜」（卡号12397569）。
	aux.AddCodeList(c,12397569)
	-- ①：把手卡·场上的这张卡送去墓地才能发动。从卡组把1张「神域 巴普-提斯蒂娜」在自己的场地区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置「神域 巴普-提斯蒂娜」"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.pcost)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「提斯蒂娜」魔法·陷阱卡被对方的效果破坏的场合，把这张卡除外才能发动。从自己的手卡·卡组·墓地把1只光属性「提斯蒂娜」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（cost）处理函数，检查并把手卡·场上的这张卡送去墓地。
function s.pcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中卡名为「神域 巴普-提斯蒂娜」且在场上唯一存在、未被禁止放置的卡。
function s.pfilter(c,tp)
	return c:IsCode(12397569) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果①的发动条件与目标检查函数，确认卡组中是否存在可放置的「神域 巴普-提斯蒂娜」。
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在满足条件的「神域 巴普-提斯蒂娜」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果①的效果处理函数，从卡组选择1张「神域 巴普-提斯蒂娜」放置到自己的场地区域。
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1张满足条件的「神域 巴普-提斯蒂娜」。
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域（序号为5的魔陷格）已存在的卡片。
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 根据规则将原本存在的场地区域卡片送去墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续的放置动作与之前的送墓动作不视为同时处理。
			Duel.BreakEffect()
		end
		-- 将选中的「神域 巴普-提斯蒂娜」在自己的场地区域表侧表示放置。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- 过滤被对方效果破坏的、自己场上表侧表示的「提斯蒂娜」魔法·陷阱卡。
function s.sfilter(c,tp,rp)
	return c:IsSetCard(0x1a4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and rp==1-tp
end
-- 效果②的触发条件函数，检查是否有满足条件的卡片被破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil,tp,rp)
end
-- 过滤手卡·卡组·墓地中可以特殊召唤的光属性「提斯蒂娜」怪兽。
function s.rfilter(c,e,tp)
	return c:IsSetCard(0x1a4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件与目标检查函数，确认怪兽区域有空位且存在可特殊召唤的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查手卡、卡组、墓地中是否存在可特殊召唤的光属性「提斯蒂娜」怪兽。
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁信息，表明该效果包含从手卡、卡组、墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的效果处理函数，从手卡·卡组·墓地选择1只光属性「提斯蒂娜」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组或墓地（适用王家长眠之谷过滤）选择1只满足条件的光属性「提斯蒂娜」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的怪兽在自己场上表侧表示特殊召唤。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
