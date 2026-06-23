--ZS－希望賢者
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡2个超量素材取除才能发动。从卡组把1只「异热同心武器」怪兽或者「异热同心从者」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤，不用「No.」怪兽不能攻击。
-- ②：除「异热同心从者-希望贤者」外的自己场上的原本属性是光属性的「霍普」超量怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
function c31123642.initial_effect(c)
	-- 为卡片添加等级为4、需要2只怪兽进行超量召唤的手续
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡2个超量素材取除才能发动。从卡组把1只「异热同心武器」怪兽或者「异热同心从者」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤，不用「No.」怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31123642,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,31123642)
	e1:SetCost(c31123642.spcost)
	e1:SetTarget(c31123642.sptg)
	e1:SetOperation(c31123642.spop)
	c:RegisterEffect(e1)
	-- ②：除「异热同心从者-希望贤者」外的自己场上的原本属性是光属性的「霍普」超量怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetTarget(c31123642.reptg)
	e2:SetValue(c31123642.repval)
	e2:SetOperation(c31123642.repop)
	c:RegisterEffect(e2)
end
-- 支付效果的代价，将自身2个超量素材移除
function c31123642.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤满足条件的怪兽：属于「异热同心武器」或「异热同心从者」卡组且可以特殊召唤
function c31123642.spfilter(c,e,tp)
	return c:IsSetCard(0x107e,0x207e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的发动条件：场上存在空位且卡组存在满足条件的怪兽
function c31123642.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c31123642.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：选择满足条件的怪兽并特殊召唤到场上，并设置后续效果限制
function c31123642.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c31123642.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置直到回合结束时自己不能从额外卡组特殊召唤非超量怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31123642.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
	-- 设置直到回合结束时自己场上的非「No.」怪兽不能攻击的效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c31123642.atklimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e2,tp)
end
-- 限制不能从额外卡组特殊召唤非超量怪兽
function c31123642.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 限制不能攻击非「No.」怪兽
function c31123642.atklimit(e,c)
	return not c:IsSetCard(0x48)
end
-- 过滤满足条件的怪兽：场上正面表示、属于「霍普」卡组、超量怪兽、光属性、不是希望贤者、被战斗或效果破坏
function c31123642.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x7f) and c:IsType(TYPE_XYZ) and c:GetOriginalAttribute()==ATTRIBUTE_LIGHT and not c:IsCode(31123642)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的发动条件：自身可以除外且有满足条件的怪兽被破坏
function c31123642.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c31123642.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 设置代替破坏的效果值为满足条件的怪兽
function c31123642.repval(e,c)
	return c31123642.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果：将自身除外
function c31123642.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身从场上除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
