--光子竜の聖騎士
-- 效果：
-- 「光子龙降临」降临。把这张卡解放才能发动。从手卡·卡组把1只「银河眼光子龙」特殊召唤。此外，这张卡战斗破坏对方怪兽送去墓地时，从卡组抽1张卡。
function c85346853.initial_effect(c)
	-- 为怪兽注册记载特定卡牌代码「光子龙降临」的关联列表
	aux.AddCodeList(c,34834619)
	c:EnableReviveLimit()
	-- 把这张卡解放才能发动。从手卡·卡组把1只「银河眼光子龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85346853,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c85346853.spcost)
	e1:SetTarget(c85346853.sptg)
	e1:SetOperation(c85346853.spop)
	c:RegisterEffect(e1)
	-- 此外，这张卡战斗破坏对方怪兽送去墓地时，从卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85346853,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c85346853.drcon)
	e2:SetTarget(c85346853.drtg)
	e2:SetOperation(c85346853.drop)
	c:RegisterEffect(e2)
end
-- 特殊召唤效果的代价，在发动时将这张卡从场上解放
function c85346853.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将当前作为发动代价的这张卡从场上解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤手牌或卡组中可以被特殊召唤的「银河眼光子龙」
function c85346853.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向，检测手牌和卡组是否存在符合要求的特召对象，并注册操作信息
function c85346853.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则确认主要怪兽区域是否还有可用的怪兽空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检测手牌或卡组中是否存在至少1只可被特殊召唤的「银河眼光子龙」
		and Duel.IsExistingMatchingCard(c85346853.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手牌或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的操作空间，从手牌或卡组选择「银河眼光子龙」并将其特殊召唤
function c85346853.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无空余怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c85346853.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选取的怪兽以正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断抽卡效果的发动条件，须为这张卡战斗破坏对方怪兽并将其送去墓地
function c85346853.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsFaceup()
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and bc:IsReason(REASON_BATTLE)
end
-- 抽卡效果的靶向判定，设定效果的目标玩家及抽卡参数，并注册抽卡操作信息
function c85346853.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设定效果的对象参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的操作空间，获取在靶向阶段设定的对象玩家与参数，并执行抽卡处理
function c85346853.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中所指定的抽卡对象玩家及抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果抽卡的形式让目标玩家从卡组抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
