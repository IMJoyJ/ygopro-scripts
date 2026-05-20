--ギミック・パペット－ファンタジクス・マキナ
-- 效果：
-- 8星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只机械族怪兽召唤。
-- ②：自己把「机关傀儡」超量怪兽特殊召唤的场合才能发动。这张卡从墓地往自己或对方的场上守备表示特殊召唤。那之后，可以从自己墓地把1张「升阶魔法」魔法卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册XYZ召唤手续、①效果和②效果
function s.initial_effect(c)
	-- 设置XYZ召唤手续：8星怪兽×2
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只机械族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索「升阶魔法」魔法卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己把「机关傀儡」超量怪兽特殊召唤的场合才能发动。这张卡从墓地往自己或对方的场上守备表示特殊召唤。那之后，可以从自己墓地把1张「升阶魔法」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：把这张卡1个超量素材取除
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中「升阶魔法」魔法卡的条件
function s.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x95) and c:IsAbleToHand()
end
-- ①效果的发动准备（检查卡组是否存在「升阶魔法」魔法卡，以及玩家是否能进行追加召唤）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「升阶魔法」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查玩家当前是否能够进行通常召唤以及追加召唤
		and Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
	-- 向对方玩家提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组检索「升阶魔法」魔法卡，并赋予本回合追加召唤机械族怪兽的效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张「升阶魔法」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 检查玩家是否可以获得追加召唤效果，且本回合尚未获得过该效果
	if Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,id)==0 then
		-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只机械族怪兽召唤。②：自己把「机关傀儡」超量怪兽特殊召唤的场合才能发动。这张卡从墓地往自己或对方的场上守备表示特殊召唤。那之后，可以从自己墓地把1张「升阶魔法」魔法卡加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"使用「机关傀儡-机械降临的粉丝幻想」的效果召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		-- 设置追加召唤的怪兽必须是机械族
		e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 给玩家注册追加召唤的效果
		Duel.RegisterEffect(e1,tp)
		-- 注册全局标识，确保该追加召唤效果每回合只能获得1次
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤自己特殊召唤的「机关傀儡」超量怪兽
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1083) and c:IsType(TYPE_XYZ) and c:IsSummonPlayer(tp)
end
-- ②效果的发动条件：自己把「机关傀儡」超量怪兽特殊召唤的场合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的发动准备（检查自己或对方场上是否有空位可以特殊召唤，并设置操作信息）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空位且这张卡能否在自己场上守备表示特殊召唤
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	-- 检查对方场上是否有空位且这张卡能否在对方场上守备表示特殊召唤
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
	if chk==0 then return b1 or b2 end
	-- 设置操作信息：特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：从墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理：将这张卡在自己或对方场上守备表示特殊召唤，之后可以从墓地把1张「升阶魔法」魔法卡加入手卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sp=false
	if c:IsRelateToEffect(e) then
		-- 检查自己场上是否仍有空位且这张卡能否在自己场上守备表示特殊召唤
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查对方场上是否仍有空位且这张卡能否在对方场上守备表示特殊召唤
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		-- 让玩家选择在自己场上特殊召唤或在对方场上特殊召唤
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3)},  --"在自己场上特殊召唤"
			{b2,aux.Stringid(id,4)})  --"在对方场上特殊召唤"
		if op==1 then
			-- 将这张卡在自己场上守备表示特殊召唤
			if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
				sp=true
			end
		else
			-- 将这张卡在对方场上守备表示特殊召唤
			if Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)>0 then
				sp=true
			end
		end
		-- 若特殊召唤成功，且墓地存在「升阶魔法」魔法卡，询问玩家是否将其加入手卡
		if sp and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then  --"是否从墓地把「升阶魔法」魔法卡加入手卡？"
			-- 中断当前效果，使后续的回收处理不与特殊召唤同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 玩家从墓地选择1张「升阶魔法」魔法卡
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选择的卡加入手卡
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方玩家确认加入手卡的卡
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
