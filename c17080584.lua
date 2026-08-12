--海皇精 アビスライン
-- 效果：
-- 这个卡名在规则上也当作「水精鳞」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和自己的手卡·场上1只「海皇」怪兽或「水精鳞」怪兽解放才能发动。从卡组选1只7星的鱼族·海龙族·水族怪兽加入手卡或特殊召唤。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
-- ②：对方回合，把墓地的这张卡除外，把1张手卡丢弃去墓地才能发动。自己抽1张。
local s,id,o=GetID()
-- 定义一个函数，用于初始化卡片效果。
function s.initial_effect(c)
	-- 创建并注册一个效果，描述为“特殊召唤”，类别为检索、特殊召唤和从卡组送墓地，类型为起动效果，具有卡片目标属性，生效范围为手牌，限制每回合使用次数为1次，设置消耗、目标和操作函数，并将该效果注册到卡片。
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
	-- 创建并注册一个效果，描述为“抽卡”，类别为抽卡，类型为速攻效果，触发条件为自由连锁，生效范围为墓地，具有玩家目标属性，限制每回合使用次数为1次，设置条件、消耗、目标和操作函数，并将该效果注册到卡片。
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
-- 定义一个过滤函数，用于检查卡片是否属于水精鳞族，并且在卡组中存在满足特定条件的卡片。
function s.cfilter(c,e,tp)
	return c:IsSetCard(0x77,0x74)
		-- 检查卡组中是否存在符合s.thfilter条件的卡片
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 定义一个消耗函数，用于释放手牌或场上的“海皇”或“水精鳞”怪兽作为效果的代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以解放卡片以及是否有满足条件的可解放卡片组
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,c,e,tp) end
	-- 选择要释放的卡片组
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,c,e,tp)
	g:AddCard(c)
	-- 释放选定的卡片组
	Duel.Release(g,REASON_COST)
end
-- 定义一个过滤函数，用于筛选符合特殊召唤条件的7星水族、鱼族或海龙族怪兽。
function s.thfilter(c,e,tp,rc)
	if not (c:IsLevel(7) and c:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT)) then return false end
	-- 判断卡片是否可以送入手牌或者特殊召唤到场上
	return c:IsAbleToHand() or (Duel.GetMZoneCount(tp,rc)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 定义一个目标函数，用于检查效果的代价是否已支付或是否存在满足条件的卡片。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查卡组中是否存在符合s.thfilter条件的卡片
		or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,nil) end
end
-- 定义一个操作函数，用于执行特殊召唤或将卡片加入手牌的效果，并注册一个场上效果以限制水属性怪兽的额外卡组特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		-- 获取当前回合玩家可用的怪兽区数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 判断是否可以送入手牌或者特殊召唤到场上
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选定的卡片加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认给对方展示的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选定的卡片特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 注册一个效果，限制水属性怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个场上效果，限制水属性怪兽从额外卡组特殊召唤
	Duel.RegisterEffect(e1,tp)
end
-- 定义一个函数，用于判断是否可以特殊召唤水属性怪兽到额外区域
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义一个条件函数，用于检查当前回合的玩家是否为对方。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义一个过滤函数，用于筛选可丢弃且可作为效果代价的卡片。
function s.costfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 定义一个消耗函数，用于将手牌作为效果的代价送入墓地。
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放卡片以及是否有满足条件的可解放卡片组
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 使用辅助函数移除卡片作为代价
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 丢弃符合条件的卡片
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 定义一个目标函数，用于确定抽卡的目标玩家。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置目标玩家为当前回合的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置目标参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息，表示这是一个抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义一个操作函数，用于执行抽卡的效果。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因进行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
