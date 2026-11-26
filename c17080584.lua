--海皇精 アビスライン
-- 效果：
-- 这个卡名在规则上也当作「水精鳞」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和自己的手卡·场上1只「海皇」怪兽或「水精鳞」怪兽解放才能发动。从卡组选1只7星的鱼族·海龙族·水族怪兽加入手卡或特殊召唤。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
-- ②：对方回合，把墓地的这张卡除外，把1张手卡丢弃去墓地才能发动。自己抽1张。
local s,id,o=GetID()
-- 初始化卡片效果，注册手卡解放发动的检索或特殊召唤①效果，以及对方回合墓地除外发动的抽卡②效果
function s.initial_effect(c)
	-- 这个卡名在规则上也当作「水精鳞」卡使用。这个卡名的①②的效果1回合各能使用1次。 ①：把手卡的这张卡和自己的手卡·场上1只「海皇」怪兽或「水精鳞」怪兽解放才能发动。从卡组选1只7星的鱼族·海龙族·水族怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。 ②：对方回合，把墓地的这张卡除外，把1张手卡丢弃去墓地才能发动。自己抽1张。
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
-- 过滤函数，检查是否为「海皇」或「水精鳞」怪兽且解放后卡组仍存在可检索或特殊召唤的目标怪兽
function s.cfilter(c,e,tp)
	return c:IsSetCard(0x77,0x74)
		-- 检查假定解放该卡时，卡组中是否存在至少1只满足条件的目标怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 发动代价处理，检查并选择解放手卡的这张卡与手卡·场上另1只「海皇」或「水精鳞」怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡的这张卡是否可解放，且手卡·场上存在其他可解放的「海皇」或「水精鳞」怪兽
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,c,e,tp) end
	-- 让控制者从手卡·场上选择1只作为代价解放的「海皇」或「水精鳞」怪兽
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,c,e,tp)
	g:AddCard(c)
	-- 将选中的怪兽与这张卡一起作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，检查是否为7星的鱼族·海龙族·水族怪兽，且能加入手卡或在解放指定怪兽后有空位时可特殊召唤
function s.thfilter(c,e,tp,rc)
	if not (c:IsLevel(7) and c:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT)) then return false end
	-- 判断该怪兽是否可加入手卡，或在解放指定怪兽后怪兽区有空位时可特殊召唤
	return c:IsAbleToHand() or (Duel.GetMZoneCount(tp,rc)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 发动条件检查，若已校验代价则直接通过，否则检查卡组是否存在满足条件的目标怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 在未经代价检查时确认卡组中是否存在至少1只满足条件的怪兽
		or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,nil) end
end
-- 效果处理，从卡组选1只7星的鱼族·海龙族·水族怪兽加入手卡或特殊召唤，并施加本回合额外卡组仅能特殊召唤水属性怪兽的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示控制者从卡组选择要加入手卡或特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1只7星的鱼族·海龙族·水族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		-- 获取自己怪兽区域的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 判断选中的怪兽是否加入手卡（可加手且无法特召、无空位或玩家选择加手时执行）
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入自己手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册持续至回合结束的额外卡组特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件，禁止将非水属性怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
-- 发动条件检查，确认当前是否为对方回合
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，检查手卡是否可作为代价丢弃并送去墓地
function s.costfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 发动代价处理，检查并将墓地的这张卡除外且丢弃1张手卡
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地的这张卡是否可以除外且手卡是否存在至少1张可丢弃的卡
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将墓地的这张卡作为发动代价除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从手卡选择1张卡作为发动代价丢弃去墓地
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 检查自己是否可以抽1张卡，并设置对象玩家、抽卡数量与操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的抽卡数量参数设置为1
	Duel.SetTargetParam(1)
	-- 设置自己抽1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理，读取对象玩家与抽卡数量并执行抽卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁设置的对象玩家与抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家依效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
