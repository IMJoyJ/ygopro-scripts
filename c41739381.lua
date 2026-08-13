--機械仕掛けの騎士
-- 效果：
-- 连接怪兽以外的原本攻击力是1000以下的机械族怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合，把自己场上1张表侧表示的永续魔法卡送去墓地才能发动。从卡组把1张「机械驱动之夜」加入手卡。
-- ②：以自己墓地1只攻击力1000以下的机械族怪兽为对象才能发动。自己场上1只其他的机械族怪兽解放，作为对象的怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片数据：登记记载卡名，设置连接召唤素材条件，创建并注册①检索效果（诱发选发）和②特殊召唤效果（起动效果），并分别设置1回合1次的次数限制。
function s.initial_effect(c)
	-- 将卡片「机械驱动之夜」（84797028）登记为这张卡记载的卡名，用于相关卡名效果联动。
	aux.AddCodeList(c,84797028)
	c:EnableReviveLimit()
	-- 为这张卡设置连接召唤手续：以1只满足s.matfilter条件的怪兽作为连接素材进行连接召唤。
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
-- 连接素材过滤条件：怪兽需为机械族、原本攻击力1000以下，且不是连接怪兽。
function s.matfilter(c)
	return c:IsLinkRace(RACE_MACHINE) and c:GetBaseAttack()<=1000
		and not c:IsLinkType(TYPE_LINK)
end
-- ①效果的发动条件：这张卡以连接召唤方式特殊召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果代价的过滤条件：选择自己场上的表侧表示永续魔法卡，且该卡可以作为代价送去墓地。
function s.cfilter(c)
	return c:IsFaceup() and c:IsAllTypes(TYPE_SPELL+TYPE_CONTINUOUS) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价处理：从自己场上选择1张表侧表示的永续魔法卡送去墓地作为发动代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：自己场上是否存在至少1张符合条件的表侧永续魔法卡可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家显示选择提示，要求选择要送去墓地的永续魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己场上选择1张符合条件的表侧表示永续魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的永续魔法卡以代价原因（REASON_COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果检索目标过滤：卡名是「机械驱动之夜」（84797028）且可以加入手卡。
function s.thfilter(c)
	return c:IsCode(84797028) and c:IsAbleToHand()
end
-- ①效果的发动目标判定：卡组存在「机械驱动之夜」时，设置将从卡组把1张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可检索的「机械驱动之夜」，决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果会从卡组把1张卡加入手卡（CATEGORY_TOHAND），用于后续效果时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时：从卡组选择1张「机械驱动之夜」加入手卡，并让对方确认检索到的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，要求选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「机械驱动之夜」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「机械驱动之夜」加入持有者的手卡（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果对象过滤：墓地中的机械族怪兽，攻击力1000以下，且可以表侧守备表示特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 解放对象的过滤条件：选择自己场上1只其他机械族怪兽作为解放对象，且解放后自己场上仍有可用的怪兽区域。
function s.rspfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsReleasableByEffect()
		-- 判定解放该怪兽后仍有可用的主要怪兽区空位，以保证后续特殊召唤能够进行。
		and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的发动检查与对象指定：验证自己场上存在可解放的机械族怪兽（除自身）且墓地存在可特殊召唤的机械族怪兽；若指定对象则检查其是否合法。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否存在1只除自身外的其他机械族怪兽可以解放。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rspfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp)
		-- 检查墓地是否存在1只可以特殊召唤的机械族怪兽作为对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只符合条件的机械族怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果会将对象怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理时：解放自己场上1只其他机械族怪兽，若解放成功且对象怪兽仍与效果关联且不受王家长眠之谷影响，则将其表侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的对象怪兽（墓地目标）。
	local tc=Duel.GetFirstTarget()
	-- 选择自己场上1只其他机械族怪兽（排除这张卡自身）作为解放对象。
	local g=Duel.SelectMatchingCard(tp,s.rspfilter,tp,LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e),tp)
	-- 确认解放成功、对象怪兽仍与效果关联且不受王家长眠之谷影响，才继续处理特殊召唤。
	if g:GetCount()>0 and Duel.Release(g,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
