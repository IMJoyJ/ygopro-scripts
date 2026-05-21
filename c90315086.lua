--ジェット・シャーク
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：场上有水属性超量怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不能把「喷水鲨」特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1只鱼族「鲨」怪兽或者1张「超量」魔法·陷阱卡送去墓地。
-- ③：把这张卡从墓地除外才能发动。从自己的卡组·墓地把1张「喷水引擎」卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤、卡组送墓、墓地除外检索三个效果。
function s.initial_effect(c)
	-- ①：场上有水属性超量怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不能把「喷水鲨」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1只鱼族「鲨」怪兽或者1张「超量」魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ③：把这张卡从墓地除外才能发动。从自己的卡组·墓地把1张「喷水引擎」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	-- 设置效果发动成本为将墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的水属性超量怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 手卡特殊召唤规则的允许条件：场上有满足条件的怪兽且自己场上有可用的怪兽区域。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查双方场上是否存在至少1只表侧表示的水属性超量怪兽，且自己场上有可用的怪兽区域。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 手卡特殊召唤规则的执行操作：注册本回合不能特殊召唤同名卡的誓约效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个方法特殊召唤过的回合，自己不能把「喷水鲨」特殊召唤。 / 从卡组把1只鱼族「鲨」怪兽或者1张「超量」魔法·陷阱卡送去墓地。 / 从自己的卡组·墓地把1张「喷水引擎」卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该限制特殊召唤的誓约效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，指定不能特殊召唤同名卡「喷水鲨」。
function s.splimit(e,c,tp,sumtp,sumpos)
	return c:IsCode(id)
end
-- 过滤条件：卡组中可以送去墓地的鱼族「鲨」怪兽或者「超量」魔法·陷阱卡。
function s.tgfilter(c)
	return (c:IsRace(RACE_FISH) and c:IsSetCard(0x1b8)
		or c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x73))
		and c:IsAbleToGrave()
end
-- 效果②（送墓）的发动准备与合法性检查。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足送墓条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示将从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②（送墓）的效果处理：从卡组选择1张满足条件的卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足送墓条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤条件：可以加入手卡的「喷水引擎」卡片。
function s.thfilter(c)
	return c:IsSetCard(0x1c2) and c:IsAbleToHand()
end
-- 效果③（检索）的发动准备与合法性检查。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理的操作信息，表示将从卡组或墓地将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③（检索）的效果处理：从卡组或墓地选择1张「喷水引擎」卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张不受王家之谷影响的「喷水引擎」卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
