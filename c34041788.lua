--エンディミオン皇国
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，把1只「圣月之皇太子 雷古勒斯」或者有那个卡名记述的怪兽从卡组加入手卡。对方场上有怪兽存在的场合，可以再从手卡把1只魔法师族怪兽特殊召唤。
-- ②：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己的手卡·场上（表侧表示）1只「圣月之皇太子 雷古勒斯」破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①发动效果和②代替破坏效果
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着「圣月之皇太子 雷古勒斯」的卡名
	aux.AddCodeList(c,96228804)
	-- ①：作为这张卡的发动时的效果处理，把1只「圣月之皇太子 雷古勒斯」或者有那个卡名记述的怪兽从卡组加入手卡。对方场上有怪兽存在的场合，可以再从手卡把1只魔法师族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己的手卡·场上（表侧表示）1只「圣月之皇太子 雷古勒斯」破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
end
-- 检索过滤器函数，用于筛选可以加入手牌的「圣月之皇太子 雷古勒斯」或其衍生物
function s.thfilter(c)
	-- 筛选条件：卡名是雷古勒斯或记载着雷古勒斯的怪兽，并且可以送去手牌
	return (c:IsCode(96228804) or aux.IsCodeListed(c,96228804) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 效果处理的判定函数，检查是否满足发动条件并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤过滤器函数，用于筛选可以特殊召唤的魔法师族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动效果的处理函数，执行检索和可能的特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查是否有足够的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查对方场上有怪兽存在
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 检查手牌中是否存在魔法师族怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 询问玩家是否特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的卡进行特殊召唤
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 代替破坏的过滤器函数，用于筛选可被代替破坏的卡
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 破坏代替的过滤器函数，用于筛选可被代替破坏的雷古勒斯
function s.desfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE+LOCATION_HAND) and c:IsCode(96228804)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的判定函数，检查是否满足发动条件
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		-- 检查场上或手牌中是否存在可代替破坏的雷古勒斯
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择满足条件的卡进行代替破坏
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 代替破坏效果的值函数，返回是否满足代替破坏条件
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，执行破坏操作
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示发动的卡牌动画
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 执行代替破坏操作
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
