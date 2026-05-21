--フォトン・ジャンパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，战斗阶段结束。这个效果发动的场合，下次的自己战斗阶段跳过。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「光子」魔法·陷阱卡或「银河」魔法·陷阱卡加入手卡。
function c97639441.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，战斗阶段结束。这个效果发动的场合，下次的自己战斗阶段跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97639441,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,97639441)
	e1:SetCondition(c97639441.spcon)
	e1:SetTarget(c97639441.sptg)
	e1:SetOperation(c97639441.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「光子」魔法·陷阱卡或「银河」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,97639442)
	e2:SetTarget(c97639441.thtg)
	e2:SetOperation(c97639441.thop)
	c:RegisterEffect(e2)
end
-- 定义效果①的发动条件函数（对方怪兽攻击宣言时）
function c97639441.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否由对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 定义效果①的发动准备函数（检查怪兽区域空位及自身能否特殊召唤）
function c97639441.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果①的效果处理函数（特殊召唤自身、结束战斗阶段并注册跳过下次战斗阶段的效果）
function c97639441.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于手卡，则将其特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理，使后续处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 跳过当前的战斗阶段（即结束战斗阶段）
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
	-- 这个效果发动的场合，下次的自己战斗阶段跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 将当前回合数记录在效果的Label中，用于后续判断
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(c97639441.skipcon)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
	-- 为玩家注册跳过战斗阶段的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义跳过战斗阶段效果的适用条件函数（非发动效果的当回合）
function c97639441.skipcon(e)
	-- 判断当前回合数是否不等于记录的回合数（即不是发动效果的当回合）
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 定义检索卡片的过滤条件（「光子」或「银河」魔法·陷阱卡）
function c97639441.thfilter(c)
	return c:IsSetCard(0x55,0x7b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 定义效果②的发动准备函数（检查卡组中是否存在符合条件的卡并设置检索信息）
function c97639441.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在符合条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c97639441.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡片加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②的效果处理函数（从卡组检索卡片并确认）
function c97639441.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,c97639441.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
