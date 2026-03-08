--機械仕掛けの騎士
-- 效果：
-- 连接怪兽以外的原本攻击力是1000以下的机械族怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合，把自己场上1张表侧表示的永续魔法卡送去墓地才能发动。从卡组把1张「机械驱动之夜」加入手卡。
-- ②：以自己墓地1只攻击力1000以下的机械族怪兽为对象才能发动。自己场上1只其他的机械族怪兽解放，作为对象的怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化效果，注册连接召唤手续并创建两个效果
function s.initial_effect(c)
	-- 记录该卡拥有「机械驱动之夜」这张卡的卡名
	aux.AddCodeList(c,84797028)
	c:EnableReviveLimit()
	-- 设置连接召唤所需素材为1~1个满足条件的怪兽
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	-- ①：这张卡连接召唤的场合，把自己场上1张表侧表示的永续魔法卡送去墓地才能发动。从卡组把1张「机械驱动之夜」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只攻击力1000以下的机械族怪兽为对象才能发动。自己场上1只其他的机械族怪兽解放，作为对象的怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 连接召唤的素材过滤器，要求是机械族、原本攻击力1000以下且不是连接怪兽
function s.matfilter(c)
	return c:IsLinkRace(RACE_MACHINE) and c:GetBaseAttack()<=1000
		and not c:IsLinkType(TYPE_LINK)
end
-- 效果发动条件：此卡为连接召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索所需支付的永续魔法卡过滤器，要求是表侧表示的永续魔法卡且能送入墓地
function s.cfilter(c)
	return c:IsFaceup() and c:IsAllTypes(TYPE_SPELL+TYPE_CONTINUOUS) and c:IsAbleToGraveAsCost()
end
-- 支付代价：选择1张满足条件的永续魔法卡送入墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索卡牌的过滤器，要求是「机械驱动之夜」且能加入手牌
function s.thfilter(c)
	return c:IsCode(84797028) and c:IsAbleToHand()
end
-- 设置检索效果的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否有满足条件的「机械驱动之夜」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，从卡组选择1张「机械驱动之夜」加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「机械驱动之夜」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 特殊召唤目标怪兽的过滤器，要求是攻击力1000以下的机械族且能特殊召唤
function s.spfilter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 解放怪兽的过滤器，要求是机械族且能因效果被解放且场上存在可用区域
function s.rspfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsReleasableByEffect()
		-- 检查场上是否有可用区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 设置特殊召唤效果的目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查场上是否有满足条件的机械族怪兽可解放
	if chk==0 then return Duel.IsExistingMatchingCard(s.rspfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp)
		-- 检查墓地是否有满足条件的机械族怪兽可特殊召唤
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果，解放1只机械族怪兽并特殊召唤目标怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 选择满足条件的场上机械族怪兽进行解放
	local g=Duel.SelectMatchingCard(tp,s.rspfilter,tp,LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e),tp)
	-- 判断是否满足特殊召唤的条件
	if g:GetCount()>0 and Duel.Release(g,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
