--武装蜂起
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只攻击力1000以下的昆虫族怪兽特殊召唤。这个效果从卡组特殊召唤的场合，再把自己场上1只怪兽送去墓地。这张卡的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的昆虫族同调怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从卡组把1张「一齐蜂起」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果，包括主要效果和墓地检索效果
function s.initial_effect(c)
	-- 记录此卡与「一齐蜂起」的关联
	aux.AddCodeList(c,52838896)
	-- ①：从手卡·卡组把1只攻击力1000以下的昆虫族怪兽特殊召唤。这个效果从卡组特殊召唤的场合，再把自己场上1只怪兽送去墓地。这张卡的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 注册卡片进入墓地时的监听效果，用于标记此卡已进入墓地
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
	-- 将此卡除外作为发动条件
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的昆虫族怪兽（攻击力1000以下）
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsAttackBelow(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在可特殊召唤的昆虫族怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组是否存在满足条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 执行主要效果：特殊召唤昆虫族怪兽，若从卡组召唤则将场上1只怪兽送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的昆虫族怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 执行特殊召唤操作
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsSummonLocation(LOCATION_DECK) then
			-- 提示玩家选择要送去墓地的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 选择场上可送去墓地的怪兽
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil)
			local gc=sg:GetFirst()
			if gc then
				-- 显示选中的怪兽被选为对象
				Duel.HintSelection(sg)
				-- 将选中的怪兽送去墓地
				Duel.SendtoGrave(gc,REASON_EFFECT)
			end
		end
	end
	-- 设置永续效果：回合结束前不能特殊召唤非昆虫族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册永续效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制非昆虫族怪兽特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT)
end
-- 筛选被破坏的昆虫族同调怪兽
function s.cfilter(c,se)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_SYNCHRO)
		and bit.band(c:GetPreviousRaceOnField(),RACE_INSECT)~=0 and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE) and (se==nil or c:GetReasonEffect()~=se)
end
-- 判断是否满足墓地效果发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,e:GetHandler(),se)
end
-- 筛选「一齐蜂起」卡
function s.thfilter(c)
	return c:IsCode(52838896) and c:IsAbleToHand()
end
-- 判断是否满足检索条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组是否存在「一齐蜂起」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：检索1张「一齐蜂起」
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行墓地效果：检索并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择「一齐蜂起」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认玩家看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
