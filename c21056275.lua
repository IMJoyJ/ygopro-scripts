--武装蜂起
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只攻击力1000以下的昆虫族怪兽特殊召唤。这个效果从卡组特殊召唤的场合，再把自己场上1只怪兽送去墓地。这张卡的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的昆虫族同调怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从卡组把1张「一齐蜂起」加入手卡。
local s,id,o=GetID()
-- 初始化函数：为「武装蜂起」注册①的发动效果（特殊召唤+送墓+自肃）和②的墓地检索效果。
function s.initial_effect(c)
	-- 记录此卡上记载了卡名「一齐蜂起」（52838896），用于相关效果的处理。
	aux.AddCodeList(c,52838896)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡·卡组把1只攻击力1000以下的昆虫族怪兽特殊召唤。这个效果从卡组特殊召唤的场合，再把自己场上1只怪兽送去墓地。这张卡的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 为这张卡注册“已在墓地”的标记检测效果，防止同一连锁中②效果的触发判定出现异常。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的昆虫族同调怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从卡组把1张「一齐蜂起」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.thcon)
	-- 设置②效果的发动代价：把这张卡自身除外（aux.bfgcost为简洁写法）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤候选过滤函数：筛选昆虫族、攻击力1000以下且可被效果特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsAttackBelow(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动判定与目标选择阶段：检查自场怪兽区空格及手卡·卡组中是否存在符合条件的昆虫族怪兽，满足条件则设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否有可用的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡·卡组中是否存在1只符合条件的昆虫族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：该效果处理时将进行特殊召唤，对象来自手卡·卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ①效果处理：若仍有可用怪兽区，从手卡·卡组选择1只符合条件的昆虫族怪兽表侧表示特殊召唤；若从卡组特殊召唤，则继续选自己场上1只怪兽送去墓地；最后赋予“不是昆虫族不能特殊召唤”的自肃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上是否有可用怪兽区。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡·卡组中选择1张符合条件的昆虫族怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 将所选怪兽以表侧表示特殊召唤到自己的怪兽区，并判断是否成功。
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsSummonLocation(LOCATION_DECK) then
			-- 提示玩家选择要送去墓地的自己场上的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 玩家从自己场上选择1张能送去墓地的怪兽。
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil)
			local gc=sg:GetFirst()
			if gc then
				-- 显示选中动画并记录该卡被选为对象。
				Duel.HintSelection(sg)
				-- 将所选怪兽因效果送去墓地。
				Duel.SendtoGrave(gc,REASON_EFFECT)
			end
		end
	end
	-- 这张卡的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。②：这张卡在墓地存在的状态，自己场上的表侧表示的昆虫族同调怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从卡组把1张「一齐蜂起」加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，影响当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制判定函数：不允许特殊召唤非昆虫族怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT)
end
-- ②效果的触发条件过滤：被战斗或效果破坏的怪兽须为表侧表示、位于主要怪兽区、种族为昆虫族的同调怪兽；同时排除与记录效果相同（se非nil且破坏原因效果相同）的情况，避免重复触发。
function s.cfilter(c,se)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_SYNCHRO)
		and bit.band(c:GetPreviousRaceOnField(),RACE_INSECT)~=0 and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE) and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的发动条件判定：当被破坏的怪兽集合中存在符合s.cfilter条件的怪兽时，本效果可以被发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,e:GetHandler(),se)
end
-- 检索目标过滤函数：卡名「一齐蜂起」且能够加入手卡。
function s.thfilter(c)
	return c:IsCode(52838896) and c:IsAbleToHand()
end
-- ②效果的发动目标判定：检查卡组中是否存在「一齐蜂起」，存在则设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在检索目标。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将检索1张卡组中的「一齐蜂起」加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张「一齐蜂起」加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张「一齐蜂起」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
