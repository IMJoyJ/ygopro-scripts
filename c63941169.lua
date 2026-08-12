--アビスチーム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己抽出自己场上的鱼族·海龙族·水族怪兽的种族种类的数量。这张卡的发动后，直到下次的自己回合的结束时自己不是水属性怪兽不能从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。自己的墓地·除外状态的1只「水精鳞」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（抽卡及额外卡组特召限制）和②效果（墓地被破坏诱发回收水精鳞）。
function s.initial_effect(c)
	-- 注册一个用于检测此卡是否已在墓地的状态标记效果，供②效果的触发条件判断使用。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：自己抽出自己场上的鱼族·海龙族·水族怪兽的种族种类的数量。这张卡的发动后，直到下次的自己回合的结束时自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。自己的墓地·除外状态的1只「水精鳞」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabelObject(e0)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的鱼族、海龙族或水族怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT)
end
-- ①效果的靶向/发动准备函数，检查玩家是否能抽卡，并计算场上符合条件的种族种类数量作为抽卡张数。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的鱼族、海龙族或水族怪兽，若无则不能发动。
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 获取自己场上所有表侧表示的鱼族、海龙族、水族怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local gc=g:GetClassCount(Card.GetRace)
	-- 步骤0：检查玩家是否可以抽出计算出的种族种类数量的卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,gc) end
	-- 设置当前连锁的效果处理对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为计算出的种族种类数量。
	Duel.SetTargetParam(gc)
	-- 设置操作信息为：自己抽卡，张数为计算出的种族种类数量。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,gc)
end
-- ①效果的处理函数，执行抽卡并对玩家施加“直到下次的自己回合结束时只能特殊召唤水属性怪兽”的额外卡组特召限制。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下次的自己回合的结束时自己不是水属性怪兽不能从额外卡组特殊召唤。自己的墓地·除外状态的1只「水精鳞」怪兽加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		-- 判断当前是否为自己的回合，以确定特召限制效果的持续时间。
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		-- 将不能从额外卡组特殊召唤非水属性怪兽的限制效果注册给玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制特召的过滤函数：不能特殊召唤非水属性的额外卡组怪兽。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：自己场上原本是表侧表示的水属性怪兽，因战斗或效果被破坏。
function s.cfilter2(c,tp,se)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:GetPreviousAttributeOnField()&ATTRIBUTE_WATER~=0
		and c:IsPreviousLocation(LOCATION_MZONE) and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的发动条件：自己场上的表侧表示的水属性怪兽被战斗·效果破坏，且排除此卡自身同时被破坏送墓的情况。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter2,1,e:GetHandler(),tp,se)
end
-- 过滤条件：墓地或除外状态的「水精鳞」怪兽。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x74) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的靶向/发动准备函数，检查并设置将墓地或除外的「水精鳞」怪兽加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己的墓地或除外状态是否存在至少1只可以加入手卡的「水精鳞」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息为：从墓地或除外状态将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的处理函数，选择自己墓地或除外状态的1只「水精鳞」怪兽加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地或除外状态选择1只满足条件的「水精鳞」怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
