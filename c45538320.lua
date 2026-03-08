--精霊術の使い魔
-- 效果：
-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「凭依」魔法·陷阱卡或「大灵术-「一轮」」加入手卡。
-- ②：宣言种族和属性各1个才能发动。这张卡直到回合结束时变成宣言的种族·属性。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地把1只守备力1500的魔法师族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册「凭依装着」卡名代码，并创建三个效果分别对应①②③效果
function s.initial_effect(c)
	-- 注册该卡为「凭依装着」卡，使其在规则上可视为「凭依装着」卡
	aux.AddCodeList(c,38057522)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「凭依」魔法·陷阱卡或「大灵术-「一轮」」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：宣言种族和属性各1个才能发动。这张卡直到回合结束时变成宣言的种族·属性。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"改变种族属性"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.artg)
	e3:SetOperation(s.arop)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地把1只守备力1500的魔法师族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 检索过滤函数，用于筛选「凭依」魔法·陷阱卡或「大灵术-「一轮」」
function s.thfilter(c)
	return (c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(38057522)) and c:IsAbleToHand()
end
-- 设置检索效果的处理条件，检查卡组是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息，提示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并把符合条件的卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认玩家手牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 改变种族属性效果的处理函数，允许玩家宣言种族和属性
function s.artg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return ((RACE_ALL&~c:GetRace())~=0 or (ATTRIBUTE_ALL&~c:GetAttribute())~=0) end
	local race,att
	-- 提示玩家选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	if ATTRIBUTE_ALL&~c:GetAttribute()==0 then
		-- 从可选种族中宣言一个种族
		race=Duel.AnnounceRace(tp,1,RACE_ALL&~c:GetRace())
	else
		-- 从所有种族中宣言一个种族
		race=Duel.AnnounceRace(tp,1,RACE_ALL)
	end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	if RACE_ALL&~c:GetRace()==0 or race==c:GetRace() then
		-- 从可选属性中宣言一个属性
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~c:GetAttribute())
	else
		-- 从所有属性中宣言一个属性
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	end
	e:SetLabel(race,att)
end
-- 改变种族属性效果的处理函数，将卡片变为宣言的种族和属性
function s.arop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rac,att=e:GetLabel()
	if c:IsRelateToChain() and c:IsFaceup() then
		if not c:IsAttribute(att) then
			-- 创建改变属性的效果，使卡片变为宣言的属性
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(att)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
		if not c:IsRace(rac) then
			-- 创建改变种族的效果，使卡片变为宣言的种族
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(rac)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end
-- 判断破坏条件，确认是否为战斗或效果破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤过滤函数，筛选守备力为1500的魔法师族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsDefense(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 设置特殊召唤效果的处理条件，检查卡组或墓地是否存在满足条件的卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组或墓地是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息，提示将从卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤效果的处理函数，选择并特殊召唤符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组或墓地中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
