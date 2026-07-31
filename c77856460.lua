--海中戦型お手伝いロボ
local s,id,o=GetID()
-- 初始化卡片效果：注册①连接召唤成功破坏对方怪兽及自身并特召墓地非水属性低攻机械族怪兽、②被除外检索攻守相同机械族怪兽、③自律计数器
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册连接召唤手续：机械族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- ①：这张卡连接召唤的场合，以对方场上1只怪兽为对象才能发动。那只对方怪兽和这张卡破坏。之后，可以从自己墓地把1只水属性以外的攻击力1600以下的机械族怪兽特殊召唤。
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
	-- ②：这张卡被除外的场合才能发动。从卡组把1只攻击力和守备力数值相同的机械族怪兽加入手卡。
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
	-- 添加自定义活动计数器：记录玩家特殊召唤非机械族怪兽的操作
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 活动计数器过滤条件：表侧表示且为机械族怪兽
function s.counterfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- ①效果发动条件：此卡连接召唤成功
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果发动Cost及誓约：检查当回合未特召非机械族怪兽，并注册当回合不能特召非机械族怪兽的限制
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：确认当回合未特召非机械族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 誓约限制：这个效果发动的回合，自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 向玩家注册当回合特召限制的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制过滤条件：非机械族怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_MACHINE)
end
-- 墓地特召过滤条件：非水属性、机械族、攻击力1600以下且可特殊召唤
function s.spfilter(c,e,tp)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_MACHINE)
		and c:IsAttackBelow(1600)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动准备：选择对方场上1只怪兽为对象并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方怪兽区域存在可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置连锁操作信息：破坏包含此卡在内的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- ①效果处理：破坏此卡与对象怪兽，成功时可从墓地特召1只满足条件的机械族怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	local dg=Group.CreateGroup()
	if c:IsRelateToChain() then dg:AddCard(c) end
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then dg:AddCard(tc) end
	-- 破坏此卡与对象怪兽，确认是否成功破坏
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)~=0
		-- 判断怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的特召目标怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择从墓地特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择1只满足条件的机械族怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 连接效果块：分隔破坏处理与墓地特殊召唤处理
			Duel.BreakEffect()
			-- 将选择的墓地怪兽表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 检索过滤条件：攻击力与守备力相同、机械族且可加入手牌
function s.thfilter(c)
	-- 判断是否为攻守数值相同且可检索的机械族怪兽
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- ②效果发动准备：设置从卡组检索卡片的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组存在攻守相同的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组把1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组把1只攻守相同的机械族怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只攻守相同的机械族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
