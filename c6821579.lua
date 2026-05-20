--R.B. VALCan Booster
-- 效果：
-- 机械族怪兽2只
-- 这张卡连接召唤的场合：可以从卡组把1张「奏悦机组」魔法卡加入手卡。
-- 这张卡在额外怪兽区域存在的场合：可以从自己的手卡·墓地把1只「奏悦机组」怪兽守备表示特殊召唤。那之后，可以把这张卡的位置向其他的自己主要怪兽区域移动。直到回合结束时，自己不是攻击力在1500以下的机械族怪兽不能从额外卡组特殊召唤。
-- 「奏悦机组 火神推进器」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：连接召唤手续、连接召唤成功的检索效果、额外怪兽区域的特召及移动效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：机械族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- 这张卡连接召唤的场合：可以从卡组把1张「奏悦机组」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这张卡在额外怪兽区域存在的场合：可以从自己的手卡·墓地把1只「奏悦机组」怪兽守备表示特殊召唤。那之后，可以把这张卡的位置向其他的自己主要怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 检查发动条件是否为连接召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤卡组中可加入手牌的「奏悦机组」魔法卡
function s.thfilter(c)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在目标卡，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「奏悦机组」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了检索效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组将1张「奏悦机组」魔法卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「奏悦机组」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查发动条件：这张卡是否在额外怪兽区域存在
function s.spcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 过滤手牌或墓地中可以守备表示特殊召唤的「奏悦机组」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特召效果的发动准备：检查怪兽区域空位及手牌/墓地中是否存在可特召的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地中是否存在可特召的「奏悦机组」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了特殊召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息：从手牌或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 特召效果的处理：特殊召唤怪兽，并可选择移动这张卡的位置，最后施加额外卡组特召限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌或墓地选择1只满足条件的「奏悦机组」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 如果成功选择怪兽，则将其以守备表示特殊召唤
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
			and c:IsRelateToChain()
			and c:IsControler(tp)
			-- 检查自己场上是否有可用于移动怪兽的空格
			and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
			-- 询问玩家是否选择将这张卡的位置移动
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否移动？"
			-- 中断当前效果处理，使后续的移动位置处理与特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要移动到的怪兽区域
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让玩家选择1个自己场上可用的主要怪兽区域空格
			local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
			-- 在界面上高亮显示玩家选择的怪兽区域
			Duel.Hint(HINT_ZONE,tp,fd)
			local seq=math.log(fd,2)
			-- 将这张卡移动到选中的怪兽区域
			Duel.MoveSequence(c,seq)
		end
	end
	-- 直到回合结束时，自己不是攻击力在1500以下的机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册该回合内限制玩家从额外卡组特殊召唤的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤条件：限制从额外卡组特殊召唤，但攻击力在1500以下的机械族怪兽除外
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_MACHINE) and c:IsAttackBelow(1500))
end
