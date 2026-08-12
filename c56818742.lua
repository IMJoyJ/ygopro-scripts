--超越竜エグザラプトル
-- 效果：
-- 包含6星以上的怪兽的恐龙族怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从手卡把1只恐龙族怪兽特殊召唤。
-- ②：这张卡所连接区的表侧表示的恐龙族怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。自己抽1张。
-- ③：这张卡被破坏的场合才能发动。从自己墓地让1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、特殊召唤时从手卡特召恐龙族、所连接区恐龙族被破坏/送墓时抽卡、自身被破坏时回收通常怪兽并特召自身的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：恐龙族怪兽2只以上，且必须包含满足s.chk过滤条件的怪兽（即6星以上怪兽）
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_DINOSAUR),2,99,s.chk)
	-- ①：这张卡特殊召唤的场合才能发动。从手卡把1只恐龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的表侧表示的恐龙族怪兽被战斗破坏的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.drcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.regcon)
	c:RegisterEffect(e3)
	-- ②：这张卡所连接区的表侧表示的恐龙族怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。自己抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
	-- ③：这张卡被破坏的场合才能发动。从自己墓地让1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,id+o*2)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetTarget(s.ssptg)
	e5:SetOperation(s.sspop)
	c:RegisterEffect(e5)
end
-- 连接素材的额外检测过滤：素材组中必须存在至少1只6星以上的怪兽
function s.chk(g)
	return g:IsExists(Card.IsLevelAbove,1,nil,6)
end
-- 过滤手卡中可以特殊召唤的恐龙族怪兽
function s.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①（手卡特召恐龙族）的发动准备与合法性检测函数
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只可以特殊召唤的恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①（手卡特召恐龙族）的效果处理函数
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特召条件的恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤在场上时为表侧表示、属于恐龙族、且在被破坏/送墓前处于这张卡连接区的怪兽
function s.cfilter(c,tp,lc)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousRaceOnField()&RACE_DINOSAUR>0 and c:IsRace(RACE_DINOSAUR)
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(lc:GetLinkedZone(),seq)>0
end
-- 效果②（战斗破坏）的发动条件：被战斗破坏的怪兽中存在满足连接区恐龙族条件的怪兽
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,e:GetHandler())
end
-- 过滤非战斗破坏原因送去墓地、且满足连接区恐龙族条件的怪兽
function s.rfilter(c,tp,lc)
	return not c:IsReason(REASON_BATTLE) and s.cfilter(c,tp,lc)
end
-- 效果②（送去墓地）的发动条件：送去墓地的怪兽中存在满足非战破连接区恐龙族条件的怪兽
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rfilter,1,nil,tp,e:GetHandler())
end
-- 满足条件时，触发自定义事件以使效果②（抽卡）入连锁发动
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，通知此卡可以发动抽卡效果
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,0,0)
end
-- 效果②（抽卡）的发动准备与合法性检测函数
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁信息，表示该效果包含抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②（抽卡）的效果处理函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家因效果抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 过滤自己墓地中可以返回卡组的通常怪兽
function s.sfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- 效果③（墓地通常怪兽回卡组并特召自身）的发动准备与合法性检测函数
function s.ssptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁信息，表示该效果包含将墓地1张卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③（墓地通常怪兽回卡组并特召自身）的效果处理函数
function s.sspop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只通常怪兽
	local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	-- 将选中的怪兽送回卡组并洗卡组，若未成功则结束处理
	if not (tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)) then return end
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，且自己场上是否有空余的怪兽区域
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查此卡是否可以特殊召唤，并询问玩家是否选择将这张卡特殊召唤
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把这张卡特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理与返回卡组不视为同时进行（错时点）
		Duel.BreakEffect()
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
