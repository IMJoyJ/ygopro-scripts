--海皇精 アビスライン
-- 效果：
-- 这个卡名在规则上也当作「水精鳞」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和自己的手卡·场上1只「海皇」怪兽或「水精鳞」怪兽解放才能发动。从卡组选1只7星的鱼族·海龙族·水族怪兽加入手卡或特殊召唤。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
-- ②：对方回合，把墓地的这张卡除外，把1张手卡丢弃去墓地才能发动。自己抽1张。
local s,id,o=GetID()
-- 创建两个效果，①为手卡发动的起动效果，②为墓地发动的速攻效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡和自己的手卡·场上1只「海皇」怪兽或「水精鳞」怪兽解放才能发动。从卡组选1只7星的鱼族·海龙族·水族怪兽加入手卡或特殊召唤。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方回合，把墓地的这张卡除外，把1张手卡丢弃去墓地才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.drcon)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否有满足条件的怪兽可以解放
function s.cfilter(c,tp)
	-- 判断怪兽是否为海皇或水精鳞卡组且场上存在可用怪兽区
	return c:IsSetCard(0x77,0x74) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动时的费用处理，需要解放手卡的自己和场上的海皇或水精鳞怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	e:SetLabel(100)
	-- 检查是否满足解放条件
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,c,tp) end
	-- 选择满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,c,tp)
	g:AddCard(c)
	-- 执行怪兽解放操作
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于检索满足条件的7星鱼族·海龙族·水族怪兽
function s.thfilter(c,e,tp,el)
	if not (c:IsLevel(7) and c:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT)) then return false end
	-- 获取玩家场上可用怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or ((ft>0 or el==100) and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果发动时的取对象处理，检查卡组是否存在满足条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
end
-- 效果发动时的处理，选择从卡组检索的怪兽并决定加入手卡或特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,0)
	-- 获取玩家场上可用怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否选择加入手卡或特殊召唤
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认玩家手卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将怪兽特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 注册效果，使本回合非水属性怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果目标过滤函数，限制非水属性怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断是否为对方回合
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，用于判断手卡是否可以丢弃
function s.costfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果发动时的费用处理，需要将墓地的卡除外并丢弃1张手卡
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外和丢弃条件
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行将卡除外的操作
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 执行丢弃手卡的操作
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 效果发动时的取对象处理，检查玩家是否可以抽卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数
	Duel.SetTargetParam(1)
	-- 设置效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动时的处理，执行抽卡操作
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
