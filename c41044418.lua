--千年の啓示
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只幻神兽族怪兽送去墓地才能发动。从自己的卡组·墓地选1张「死者苏生」加入手卡。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。这个回合，可以用自己的「死者苏生」把自己墓地的「太阳神之翼神龙」无视召唤条件特殊召唤。这个效果发动的回合的结束阶段，自己必须把「死者苏生」的效果特殊召唤的「太阳神之翼神龙」送去墓地。
function c41044418.initial_effect(c)
	-- aux.AddCodeList(c,10000010) 将卡号10000010（太阳神之翼神龙）登记到这张卡的卡名关联列表中，使游戏能识别这张卡的效果涉及该卡名。
	aux.AddCodeList(c,10000010)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从手卡把1只幻神兽族怪兽送去墓地才能发动。从自己的卡组·墓地选1张「死者苏生」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41044418,0))  --"检索或回收"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,41044418)
	e1:SetCost(c41044418.thcost)
	e1:SetTarget(c41044418.thtg)
	e1:SetOperation(c41044418.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。这个回合，可以用自己的「死者苏生」把自己墓地的「太阳神之翼神龙」无视召唤条件特殊召唤。这个效果发动的回合的结束阶段，自己必须把「死者苏生」的效果特殊召唤的「太阳神之翼神龙」送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41044418,1))  --"准备死苏翼神龙"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,41044419)
	e2:SetCondition(c41044418.rbcon)
	e2:SetCost(c41044418.rbcost)
	e2:SetTarget(c41044418.rbtg)
	e2:SetOperation(c41044418.rbop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选满足①发动代价的怪兽——种族为幻神兽族，且可以从手牌送去墓地作为代价。
function c41044418.costfilter(c)
	return c:IsRace(RACE_DIVINE) and c:IsAbleToGraveAsCost()
end
-- ①的代价处理：玩家从手牌选择1只幻神兽族怪兽并送去墓地作为发动条件。
function c41044418.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认手牌中存在至少1只可作为代价的幻神兽族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41044418.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给出选择提示，请求玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择1张满足代价条件的幻神兽族怪兽。
	local g=Duel.SelectMatchingCard(tp,c41044418.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选怪兽送去墓地，原因记为代价送墓。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：筛选卡名为「死者苏生」（卡号83764718）且可以被加入手牌的卡。
function c41044418.thfilter(c)
	return c:IsCode(83764718) and c:IsAbleToHand()
end
-- ①的目标检查与操作信息设置：确认卡组·墓地存在「死者苏生」，并设置将1张卡从这些区域加入手牌的操作信息。
function c41044418.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己的卡组或墓地中至少存在1张「死者苏生」。
	if chk==0 then return Duel.IsExistingMatchingCard(c41044418.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从自己的卡组·墓地（不取对象）选1张卡加入手牌，分类设为回手牌/检索。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①的效果处理：从卡组·墓地选择1张「死者苏生」加入手牌，并向对手展示。
function c41044418.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示，请求玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组·墓地选择1张符合条件且不受王家长眠之谷影响的「死者苏生」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41044418.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「死者苏生」加入持有者手牌，处理原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示刚才加入手牌的「死者苏生」。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②的发动条件判定：这张卡在魔法与陷阱区域表侧表示且效果有效。
function c41044418.rbcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- ②的代价处理：将魔法与陷阱区域表侧表示的这张卡自身送去墓地。
function c41044418.rbcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡自身送去墓地，作为发动②的代价。
	Duel.SendtoGrave(c,REASON_COST)
end
-- ②的目标检查：确认本回合还没有通过②效果获得特召许可（即标志41044418不存在）。
function c41044418.rbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：当前玩家本回合尚未使用过②效果（标志41044418数量为0）。
	if chk==0 then return Duel.GetFlagEffect(tp,41044418)==0 end
end
-- ②的效果处理：为本回合设置『可用自己的死者苏生把墓地的太阳神之翼神龙无视召唤条件特殊召唤』的许可，并注册特殊召唤监测、结束阶段强制送墓的效果，最后记录已发动标志。
function c41044418.rbop(e,tp,eg,ep,ev,re,r,rp)
	-- 防止重复处理：若标志41044418已存在，说明②效果已经处理过，直接返回。
	if Duel.GetFlagEffect(tp,41044418)~=0 then return end
	local c=e:GetHandler()
	-- 这个回合，可以用自己的「死者苏生」把自己墓地的「太阳神之翼神龙」无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(41044418)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述玩家目标效果注册给当前玩家，持续到这个回合结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 这个效果发动的回合的结束阶段，自己必须把「死者苏生」的效果特殊召唤的「太阳神之翼神龙」送去墓地。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetReset(RESET_PHASE+PHASE_END)
	e0:SetCondition(c41044418.regcon)
	e0:SetOperation(c41044418.regop)
	-- 将特殊召唤成功监测效果注册给当前玩家，用来识别通过死者苏生特殊召唤成功的翼神龙。
	Duel.RegisterEffect(e0,tp)
	-- 这个效果发动的回合的结束阶段，自己必须把「死者苏生」的效果特殊召唤的「太阳神之翼神龙」送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c41044418.tgcon)
	e2:SetOperation(c41044418.tgop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段的强制送墓效果注册给当前玩家。
	Duel.RegisterEffect(e2,tp)
	-- 为当前玩家注册标志41044418，持续到结束阶段，表示本回合已发动过②效果，防止重复使用。
	Duel.RegisterFlagEffect(tp,41044418,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：判断一只怪兽是否为通过「死者苏生」特殊召唤的「太阳神之翼神龙」，用于结束阶段识别。
function c41044418.regfilter(c)
	local code,code2=c:GetSpecialSummonInfo(SUMMON_INFO_CODE,SUMMON_INFO_CODE2)
	return c:IsCode(10000010) and (c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_MONSTER_REBORN or code==83764718 or code2==83764718)
end
-- 监测触发条件：本次特殊召唤成功的怪兽中存在符合上述条件的「太阳神之翼神龙」。
function c41044418.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41044418.regfilter,1,nil)
end
-- 处理函数：为通过死者苏生特殊召唤成功的「太阳神之翼神龙」打上标记，使其在结束阶段被检索到。
function c41044418.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c41044418.regfilter,nil)
	-- 遍历目标怪兽组中的每一只怪兽。
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(41044418,RESET_EVENT+0x1fe0000,0,0)
	end
end
-- 过滤函数：筛选自己场上表侧表示且带有标记41044418的「太阳神之翼神龙」。
function c41044418.tgfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(41044418)~=0
end
-- 强制送墓的触发条件：自己场上存在至少1只需要在结束阶段送去墓地的翼神龙。
function c41044418.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 合法性检查：确认场上存在符合强制送墓条件的「太阳神之翼神龙」。
	return Duel.IsExistingMatchingCard(c41044418.tgfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 结束阶段处理：将自己场上所有带有标记的「太阳神之翼神龙」以规则原因送去墓地。
function c41044418.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有需要强制送去墓地的「太阳神之翼神龙」的集合。
	local g=Duel.GetMatchingGroup(c41044418.tgfilter,tp,LOCATION_MZONE,0,nil)
	-- 为这些将被送墓的怪兽播放选中动画效果并进行对象登记。
	Duel.HintSelection(g)
	-- 将这些「太阳神之翼神龙」以规则原因送去墓地，完成结束阶段的强制送墓。
	Duel.SendtoGrave(g,REASON_RULE)
end
