--瘴煙の死霊術師
-- 效果：
-- 包含魔法师族·暗属性怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己墓地把1只5星以上的魔法师族·暗属性怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
-- ②：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。进行1只魔法师族怪兽的召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、①效果（连接召唤成功时回收墓地魔法师族·暗属性怪兽）和②效果（送墓魔陷进行魔法师族怪兽的通常召唤）。
function s.initial_effect(c)
	-- 设定连接召唤手续：需要2只怪兽作为素材，且必须满足s.lcheck过滤条件（包含魔法师族·暗属性怪兽）。
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从自己墓地把1只5星以上的魔法师族·暗属性怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收效果"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。进行1只魔法师族怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.sumcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
-- 过滤连接素材：魔法师族且暗属性的怪兽。
function s.lfilter(c)
	return c:IsLinkRace(RACE_SPELLCASTER) and c:IsLinkAttribute(ATTRIBUTE_DARK)
end
-- 检查连接素材组中是否至少存在1只满足s.lfilter过滤条件（魔法师族·暗属性）的怪兽。
function s.lcheck(g)
	return g:IsExists(s.lfilter,1,nil)
end
-- ①效果的发动条件：这张卡是连接召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤回收目标：5星以上的魔法师族·暗属性怪兽，且能加入手卡。
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- ①效果的发动准备（Target）：检查墓地是否存在符合条件的怪兽，并设置回收卡片的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的5星以上魔法师族·暗属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从自己墓地将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果的效果处理（Operation）：将墓地1只符合条件的怪兽加入手卡，并给该卡及同名卡注册本回合不能发动效果的限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1只满足条件且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 选中卡片时在场上/墓地显示选中动画。
	Duel.HintSelection(g)
	-- 尝试将选中的卡加入手卡，若成功加入且该卡确实存在于手卡中。
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,tc)
		-- 这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。②：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。进行1只魔法师族怪兽的召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该回合内不能发动该卡及同名卡效果的玩家限制效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制发动效果的过滤函数：若发动的效果属于被加入手卡的卡片（或其同名卡），则不能发动。
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
-- 过滤送墓的Cost卡片：必须是能送去墓地的魔法·陷阱卡，且此时手卡或场上存在可以召唤的魔法师族怪兽（排除作为Cost的卡本身）。
function s.cfilter(c,tp)
	return c:IsAbleToGraveAsCost() and c:IsType(TYPE_SPELL+TYPE_TRAP)
		-- 检查手卡或场上（排除当前作为Cost的卡）是否存在可以进行通常召唤的魔法师族怪兽。
		and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c)
end
-- ②效果的发动代价（Cost）：从自己的手卡或场上选择1张魔法·陷阱卡送去墓地。
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可以作为Cost送去墓地的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或场上选择1张魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤召唤目标：魔法师族怪兽，且当前状态下可以进行通常召唤。
function s.sumfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsSummonable(true,nil)
end
-- ②效果的发动准备（Target）：检查手卡或场上是否存在可召唤的魔法师族怪兽，并设置召唤的操作信息。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在至少1只可以进行通常召唤的魔法师族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：进行1只怪兽的通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果的效果处理（Operation）：让玩家选择手卡或场上的一只魔法师族怪兽进行通常召唤。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡或场上选择1只满足召唤条件的魔法师族怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 让玩家对选中的怪兽进行通常召唤（忽略每回合的通常召唤次数限制）。
		Duel.Summon(tp,tc,true,nil)
	end
end
