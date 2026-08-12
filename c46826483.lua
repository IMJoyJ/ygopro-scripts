--ダークティラノ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：魔法卡的效果发动的回合的自己主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：只要对方场上的怪兽全部是守备表示，这张卡可以直接攻击。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把1只8星以上的恐龙族怪兽加入手卡。对方场上有怪兽存在的场合，可以再把加入手卡的那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（手卡起动效果，满足条件时从手卡特殊召唤这张卡，1回合1次）、②效果（对方场上怪兽全部是守备表示时可以直接攻击的永续效果）、③效果（送去墓地场合的诱发选发效果，从卡组检索8星以上恐龙族怪兽并可特殊召唤，1回合1次），并设置魔法卡效果发动的自定义计数器
function s.initial_effect(c)
	-- ①：魔法卡的效果发动的回合的自己主要阶段才能发动。这张卡从手卡特殊召唤。（这个卡名的①的效果1回合能使用1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要对方场上的怪兽全部是守备表示，这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.dircon)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把1只8星以上的恐龙族怪兽加入手卡。对方场上有怪兽存在的场合，可以再把加入手卡的那只怪兽特殊召唤。（这个卡名的③的效果1回合能使用1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- 注册自定义计数器：每当有非魔法卡以外的效果发动（即魔法卡的效果发动）时计数，用于检测「魔法卡的效果发动的回合」这一发动条件
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 计数器过滤函数：当发动的效果不是魔法卡的效果类型时返回true（计数器不增加），即只有魔法卡的效果发动才会被计数
function s.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_SPELL)
end
-- ①效果的发动条件：判断本回合是否有玩家发动过魔法卡的效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己或对方的魔法卡效果发动计数是否大于0，即本回合是否有魔法卡的效果发动过
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0 or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- ①效果的目标函数：发动时检查自己主要怪兽区是否有空格且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己主要怪兽区存在可用空格，且这张卡满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本效果将特殊召唤这张卡自身（1张），用于星尘龙等效果的连锁检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍与连锁相关联，则将这张卡从手卡以正面表示特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以正面攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断怪兽是否为攻击表示
function s.cfilter(c)
	return c:IsPosition(POS_ATTACK)
end
-- ②效果的适用条件：对方场上存在怪兽，且对方场上不存在攻击表示的怪兽（即对方场上的怪兽全部是守备表示）
function s.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方主要怪兽区是否存在至少1只怪兽
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 检查对方主要怪兽区不存在攻击表示的怪兽，即对方场上的怪兽全部是守备表示
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 检索过滤函数：判断卡片是否为8星以上且可以加入手卡的恐龙族怪兽
function s.thfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevelAbove(8) and c:IsAbleToHand()
end
-- ③效果的目标函数：发动时检查卡组是否存在可检索的8星以上恐龙族怪兽，并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：卡组中存在至少1只满足条件的8星以上恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果将从卡组把1张卡加入手卡，用于其他效果的连锁检测
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的处理：从卡组选1只8星以上的恐龙族怪兽加入手卡并向对方确认；之后若对方场上有怪兽存在、自己场上有空格且该怪兽可以特殊召唤，询问玩家后可以再把加入手卡的那只怪兽特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己玩家从卡组选择1只满足条件的8星以上恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽以效果原因加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡出示给对方确认
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		-- 检查对方场上是否存在怪兽
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 检查自己主要怪兽区是否还有可用空格
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问玩家是否将加入手卡的那只怪兽特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤与加入手卡不作为同时处理（避免错时点）
			Duel.BreakEffect()
			-- 将加入手卡的那只怪兽以正面攻击表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
