--空牙団の積荷 レクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「空牙团」魔法·陷阱卡加入手卡。
-- ②：自己·对方的主要阶段，自己场上有「空牙团」怪兽存在的场合，把墓地的这张卡除外，以自己墓地1张「空牙团」卡为对象才能发动。那张卡加入手卡。作为对象的卡是怪兽的场合，也能不加入手卡特殊召唤。
local s,id,o=GetID()
-- 注册两个诱发选发效果，分别在通常召唤和特殊召唤成功时发动，效果为检索1张空牙团魔法·陷阱卡加入手牌
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「空牙团」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方的主要阶段，自己场上有「空牙团」怪兽存在的场合，把墓地的这张卡除外，以自己墓地1张「空牙团」卡为对象才能发动。那张卡加入手卡。作为对象的卡是怪兽的场合，也能不加入手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	-- 将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检索满足条件的空牙团魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x114) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息，确定要检索的卡为1张空牙团魔法·陷阱卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即场上是否存在至少1张空牙团魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择1张空牙团魔法·陷阱卡加入手牌并确认给对手
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张空牙团魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于判断场上是否存在空牙团怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- 判断是否满足效果发动条件，即当前阶段为主阶段且场上存在空牙团怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前阶段是否为主阶段1或主阶段2，并且场上是否存在空牙团怪兽
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断墓地中的空牙团卡是否可以加入手牌或特殊召唤
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x114) then return false end
	-- 判断目标玩家场上是否有空余召唤位置
	local sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if c:IsType(TYPE_MONSTER) then
		return c:IsAbleToHand() or sp and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	else return c:IsAbleToHand() end
end
-- 设置效果目标，选择墓地中的空牙团卡作为对象，并根据对象类型设置效果分类
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 判断是否满足选择目标的条件，即墓地中是否存在至少1张空牙团卡
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张空牙团卡作为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置连锁操作信息，表示将要将选中的卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 执行效果处理，根据对象卡类型决定是加入手牌还是特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER)
		-- 判断目标卡是否可以特殊召唤，即目标玩家场上是否有空余召唤位置且目标卡可以被特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是否选择特殊召唤，若目标卡不能加入手牌则由玩家选择是否特殊召唤
		and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
