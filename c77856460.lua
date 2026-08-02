--海中戦型お手伝いロボ
local s,id,o=GetID()
-- 初始化函数，注册连接召唤条件和各个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤条件为2只机械族怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- ①：这张卡连接召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽和这张卡破坏。那之后，可以从自己墓地选1只水属性以外的机械族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。从卡组把1只攻击力与守备力相同的机械族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 设置一个自定义指示器，用于记录玩家特殊召唤机械族怪兽的操作
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤函数，检查是否是表侧表示的机械族怪兽
function s.counterfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- 判断这张卡是否是通过连接召唤出场的
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果1的cost函数，判断是否满足特召限制，并施加本回合不能特殊召唤机械族以外怪兽的自肃
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否进行过机械族以外的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 向玩家注册一个誓约效果，直到回合结束时不能特殊召唤机械族以外的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将上述限制特召的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤条件，禁止特殊召唤非机械族怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_MACHINE)
end
-- 检查卡片是否是水属性以外、攻击力1600以下的机械族怪兽，且能被特殊召唤
function s.spfilter(c,e,tp)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_MACHINE)
		and c:IsAttackBelow(1600)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1的发动目标设定，选择对方场上1只怪兽和这张卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置操作信息：预期破坏选择的怪兽和这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果1的处理逻辑，破坏对象怪兽和这张卡，然后选择是否从墓地特召怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	local dg=Group.CreateGroup()
	if c:IsRelateToChain() then dg:AddCard(c) end
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then dg:AddCard(tc) end
	-- 判断指定的卡是否被成功破坏
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)~=0
		-- 判断当前主要怪兽区是否还有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足特召条件的怪兽，且不受王家长眠之谷影响
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否要执行特殊召唤的操作
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从墓地选择1只满足条件的怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 中断当前效果，使前后的效果处理不视为同时发生
			Duel.BreakEffect()
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数，检查卡片是否是攻击力和守备力相同的机械族怪兽，且能加入手卡
function s.thfilter(c)
	-- 检查卡片是否攻击力和守备力相同，且是机械族，且能加入手卡
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 效果2的发动目标设定，检索卡组中满足条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预期从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果2的处理逻辑，让玩家从卡组选卡加入手卡并展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
