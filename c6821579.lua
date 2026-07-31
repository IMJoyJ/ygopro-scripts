--R.B.バルカンブースター
-- 效果：
-- 机械族怪兽2只
-- 这张卡连接召唤的场合：可以从卡组把1张「奏悦机组」魔法卡加入手卡。
-- 这张卡在额外怪兽区域存在的场合：可以从自己的手卡·墓地把1只「奏悦机组」怪兽守备表示特殊召唤。那之后，可以把这张卡的位置向其他的自己主要怪兽区域移动。直到回合结束时，自己不是攻击力在1500以下的机械族怪兽不能从额外卡组特殊召唤。
-- 「奏悦机组 火神推进器」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①连接召唤检索魔法效果、②额外怪兽区特召并移动位置及誓约限制效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：机械族怪兽2只
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
	-- 这张卡在额外怪兽区域存在的场合：可以从自己的手卡·墓地把1只「奏悦机组」怪兽守备表示特殊召唤。那之后，可以把这张卡的位置向其他的自己主要怪兽区域移动。直到回合结束时，自己不是攻击力在1500以下的机械族怪兽不能从额外卡组特殊召唤。
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
-- ①效果发动条件：此卡连接召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤条件：卡名包含「奏悦机组」的魔法卡且可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ①效果发动准备：设置从卡组检索魔法卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在符合条件的「奏悦机组」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息：从卡组把1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组把1张「奏悦机组」魔法卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「奏悦机组」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果发动条件：此卡在额外怪兽区域
function s.spcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 特殊召唤过滤条件：卡名包含「奏悦机组」且能守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果发动准备：设置从手牌/墓地特殊召唤怪兽的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在符合条件的「奏悦机组」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息：从手牌/墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ②效果处理：守备表示特召「奏悦机组」怪兽，可移动自身位置，并施加额外卡组特召限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查主要怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌/墓地选择1只符合条件的「奏悦机组」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的怪兽表侧守备表示特殊召唤成功
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
			and c:IsRelateToChain()
			and c:IsControler(tp)
			-- 检查是否存在空置的自己主要怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
			-- 询问玩家是否移动此卡的位置
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否移动？"
			-- 连接效果块（分隔特殊召唤与移动位置的操作）
			Duel.BreakEffect()
			-- 提示玩家选择要移动到的位置
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让玩家选择1个空置的主要怪兽区域
			local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
			-- 高亮显示玩家选择的位置
			Duel.Hint(HINT_ZONE,tp,fd)
			local seq=math.log(fd,2)
			-- 将此卡移动到选择的怪兽区域
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
	-- 为玩家注册直到回合结束的额外卡组特殊召唤限制
	Duel.RegisterEffect(e1,tp)
end
-- 额外卡组特召限制过滤：禁止从额外卡组特殊召唤非攻击力1500以下的机械族怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_MACHINE) and c:IsAttackBelow(1500))
end
