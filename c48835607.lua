--オルフェゴール・ガラテアi
-- 效果：
-- 「自奏圣乐」怪兽或「星遗物」怪兽1只
-- 自己对「自奏圣乐·伽拉忒亚i」1回合只能有1次连接召唤。这张卡不能作为超量召唤的素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：把1张手卡送去墓地才能发动。从自己的卡组·墓地把1只「星遗物」怪兽或1张「自奏圣乐的通天塔」加入手卡。
-- ②：这张卡在墓地存在的场合，从自己墓地把1张其他的「自奏圣乐」卡除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，设置卡片的连接召唤条件、超量素材限制、特殊召唤限制及两个效果
function s.initial_effect(c)
	-- 为卡片添加编号90351981的代码列表，用于效果判定
	aux.AddCodeList(c,90351981)
	-- 设置连接召唤所需素材为满足s.matfilter条件的怪兽，最少1个，最多1个
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	-- 效果作用：该卡不能作为超量召唤的素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 效果作用：特殊召唤成功时，使自己在本回合不能特殊召唤同名卡
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 效果作用：从手牌送去墓地检索「星遗物」怪兽或「自奏圣乐的通天塔」加入手牌
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.accon1)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.accon2)
	c:RegisterEffect(e4)
	-- 效果作用：从墓地特殊召唤，需要除外一张其他「自奏圣乐」卡作为代价
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"墓地特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+o)
	e5:SetCondition(s.accon1)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCondition(s.accon2)
	c:RegisterEffect(e6)
end
-- 连接素材过滤函数，要求怪兽为「自奏圣乐」或「星遗物」系列
function s.matfilter(c)
	return c:IsLinkSetCard(0x11b,0xfe)
end
-- 条件函数，判断该卡是否为连接召唤成功
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 操作函数，注册一个在本回合不能特殊召唤同名卡的效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检索满足条件的卡片并加入手牌，以及墓地特殊召唤效果的处理函数
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果函数，禁止特殊召唤指定编号的卡且必须为连接召唤方式
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 条件函数，判断当前是否不能发动起动效果（即非对方回合）
function s.accon1(e,tp,eg,ep,ev,re,r,rp)
	-- 返回值：当前卡片不处于对方回合时的效果触发条件
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 条件函数，判断当前是否可以发动诱发即时效果（即对方回合）
function s.accon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回值：当前卡片处于对方回合时的效果触发条件
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 检索效果的费用支付函数，需要将一张手牌送去墓地作为代价
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的手牌可以送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的一张手牌送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 执行将选中卡送去墓地的操作
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索效果的过滤函数，用于筛选可加入手牌的卡片
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsCode(90351981) or (c:IsSetCard(0xfe) and c:IsType(TYPE_MONSTER)))
end
-- 检索效果的目标设定函数，检查是否有满足条件的卡片可以检索
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡片可以检索
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为检索一张卡到手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果的处理函数，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的一张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 执行将选中卡加入手牌的操作
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 墓地特殊召唤效果的费用过滤函数，用于筛选可除外的「自奏圣乐」卡
function s.costfilter(c)
	return c:IsSetCard(0x11b) and c:IsAbleToRemoveAsCost()
end
-- 墓地特殊召唤效果的费用支付函数，需要除外一张其他「自奏圣乐」卡作为代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的墓地卡可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的一张卡除外
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 执行将选中卡除外的操作
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 墓地特殊召唤效果的目标设定函数，检查是否可以特殊召唤该卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场地位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤一张卡到场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地特殊召唤效果的处理函数，执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否满足特殊召唤条件且未受王家长眠之谷影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 执行将该卡特殊召唤的操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
