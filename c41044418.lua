--千年の啓示
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只幻神兽族怪兽送去墓地才能发动。从自己的卡组·墓地选1张「死者苏生」加入手卡。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。这个回合，可以用自己的「死者苏生」把自己墓地的「太阳神之翼神龙」无视召唤条件特殊召唤。这个效果发动的回合的结束阶段，自己必须把「死者苏生」的效果特殊召唤的「太阳神之翼神龙」送去墓地。
function c41044418.initial_effect(c)
	-- 注册此卡为「死者苏生」的替代卡名
	aux.AddCodeList(c,10000010)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：从手卡把1只幻神兽族怪兽送去墓地才能发动。从自己的卡组·墓地选1张「死者苏生」加入手卡。
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
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。这个回合，可以用自己的「死者苏生」把自己墓地的「太阳神之翼神龙」无视召唤条件特殊召唤。这个效果发动的回合的结束阶段，自己必须把「死者苏生」的效果特殊召唤的「太阳神之翼神龙」送去墓地。
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
-- 过滤函数：判断是否为幻神兽族且可作为墓地代价的怪兽
function c41044418.costfilter(c)
	return c:IsRace(RACE_DIVINE) and c:IsAbleToGraveAsCost()
end
-- 效果发动时的费用处理：选择1只手牌中的幻神兽族怪兽送去墓地
function c41044418.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用条件：手牌中是否存在幻神兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41044418.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的幻神兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c41044418.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：判断是否为「死者苏生」
function c41044418.thfilter(c)
	return c:IsCode(83764718) and c:IsAbleToHand()
end
-- 效果发动时的处理：确认卡组或墓地是否存在「死者苏生」
function c41044418.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组或墓地是否存在「死者苏生」
	if chk==0 then return Duel.IsExistingMatchingCard(c41044418.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息：将1张「死者苏生」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果发动时的处理：选择1张「死者苏生」加入手牌
function c41044418.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「死者苏生」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41044418.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「死者苏生」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果发动条件：此卡处于表侧表示状态
function c41044418.rbcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 效果发动时的费用处理：将此卡送去墓地
function c41044418.rbcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为费用
	Duel.SendtoGrave(c,REASON_COST)
end
-- 效果发动时的处理：确认是否已使用过此效果
function c41044418.rbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已使用过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,41044418)==0 end
end
-- 效果发动时的处理：设置效果标识，注册连续效果和结束阶段处理
function c41044418.rbop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已使用过此效果，若已使用则不继续处理
	if Duel.GetFlagEffect(tp,41044418)~=0 then return end
	local c=e:GetHandler()
	-- 创建一个影响玩家的字段效果，使该玩家的「死者苏生」可特殊召唤「太阳神之翼神龙」
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(41044418)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将字段效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 创建一个持续效果，监听特殊召唤成功事件
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetReset(RESET_PHASE+PHASE_END)
	e0:SetCondition(c41044418.regcon)
	e0:SetOperation(c41044418.regop)
	-- 将持续效果注册给玩家
	Duel.RegisterEffect(e0,tp)
	-- 创建一个持续效果，监听回合结束阶段
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c41044418.tgcon)
	e2:SetOperation(c41044418.tgop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将回合结束阶段效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	-- 注册一个全局标识效果，防止此效果重复使用
	Duel.RegisterFlagEffect(tp,41044418,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：判断是否为「太阳神之翼神龙」或其特殊召唤方式为「死者苏生」召唤
function c41044418.regfilter(c)
	local code,code2=c:GetSpecialSummonInfo(SUMMON_INFO_CODE,SUMMON_INFO_CODE2)
	return c:IsCode(10000010) and (c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_MONSTER_REBORN or code==83764718 or code2==83764718)
end
-- 条件函数：判断是否有满足条件的特殊召唤怪兽
function c41044418.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41044418.regfilter,1,nil)
end
-- 操作函数：为特殊召唤的怪兽注册标识效果
function c41044418.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c41044418.regfilter,nil)
	-- 遍历特殊召唤的怪兽组
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(41044418,RESET_EVENT+0x1fe0000,0,0)
	end
end
-- 过滤函数：判断是否为已标记的「太阳神之翼神龙」
function c41044418.tgfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(41044418)~=0
end
-- 条件函数：判断是否有已标记的「太阳神之翼神龙」
function c41044418.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足条件：场上有已标记的「太阳神之翼神龙」
	return Duel.IsExistingMatchingCard(c41044418.tgfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 操作函数：将标记的「太阳神之翼神龙」送去墓地
function c41044418.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的已标记「太阳神之翼神龙」
	local g=Duel.GetMatchingGroup(c41044418.tgfilter,tp,LOCATION_MZONE,0,nil)
	-- 显示被选为对象的卡
	Duel.HintSelection(g)
	-- 将满足条件的卡送去墓地
	Duel.SendtoGrave(g,REASON_RULE)
end
