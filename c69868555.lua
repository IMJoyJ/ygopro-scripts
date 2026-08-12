--巨神竜の遺跡
-- 效果：
-- ①：自己场上有7·8星的龙族怪兽存在，从墓地以外有怪兽特殊召唤的场合发动。那些怪兽的效果直到回合结束时无效化。
-- ②：1回合1次，把这张卡以外的自己场上1张表侧表示的卡送去墓地才能发动。在自己场上把1只「巨龙衍生物」（龙族·光·1星·攻/守0）特殊召唤。
-- ③：这张卡在墓地存在的场合，把自己的手卡·场上1只7·8星的龙族怪兽送去墓地才能发动。这张卡加入手卡。
function c69868555.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有7·8星的龙族怪兽存在，从墓地以外有怪兽特殊召唤的场合发动。那些怪兽的效果直到回合结束时无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69868555,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c69868555.discon)
	e2:SetTarget(c69868555.distg)
	e2:SetOperation(c69868555.disop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡以外的自己场上1张表侧表示的卡送去墓地才能发动。在自己场上把1只「巨龙衍生物」（龙族·光·1星·攻/守0）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69868555,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c69868555.tkcost)
	e3:SetTarget(c69868555.tktg)
	e3:SetOperation(c69868555.tkop)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的场合，把自己的手卡·场上1只7·8星的龙族怪兽送去墓地才能发动。这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69868555,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c69868555.thcost)
	e4:SetTarget(c69868555.thtg)
	e4:SetOperation(c69868555.thop)
	c:RegisterEffect(e4)
end
-- 过滤非从墓地特殊召唤的怪兽（或原本是陷阱卡的怪兽）
function c69868555.cfilter(c)
	return not c:IsSummonLocation(LOCATION_GRAVE) or (c:GetOriginalType()&TYPE_TRAP~=0)
end
-- 过滤自己场上表侧表示的7·8星龙族怪兽（且不包含在本次特殊召唤的怪兽中）
function c69868555.dfilter(c,eg)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and not eg:IsContains(c)
end
-- 效果①的发动条件判定函数
function c69868555.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特殊召唤的怪兽中是否存在从墓地以外特招的怪兽，且自己场上存在7·8星的龙族怪兽
	return eg:IsExists(c69868555.cfilter,1,nil) and Duel.IsExistingMatchingCard(c69868555.dfilter,tp,LOCATION_MZONE,0,1,nil,eg)
end
-- 效果①的发动准备与目标确认函数
function c69868555.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(69868555)==0 end
	e:GetHandler():RegisterFlagEffect(69868555,RESET_CHAIN,0,1)
	local g=eg:Filter(c69868555.cfilter,nil)
	-- 将满足条件的特殊召唤怪兽设为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置效果无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 过滤出场上表侧表示、是效果怪兽、满足非墓地特招条件且仍与效果关联的怪兽
function c69868555.filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c69868555.cfilter(c) and c:IsRelateToEffect(e)
end
-- 效果①的效果处理函数（使目标怪兽效果无效）
function c69868555.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c69868555.filter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那些怪兽的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 过滤场上表侧表示且可以作为cost送去墓地的卡
function c69868555.tkcostfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 效果②的发动代价（Cost）处理函数
function c69868555.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_ONFIELD
	if ft==0 then loc=LOCATION_MZONE end
	-- 检查是否满足发动代价（怪兽区有空位或有可送墓的怪兽，且场上有除这张卡以外的表侧表示卡片）
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c69868555.tkcostfilter,tp,loc,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张除这张卡以外的自己场上的表侧表示卡片
	local g=Duel.SelectMatchingCard(tp,c69868555.tkcostfilter,tp,loc,0,1,1,e:GetHandler())
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的发动准备与目标确认函数
function c69868555.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够特殊召唤指定的衍生物
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,69868556,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_DRAGON,ATTRIBUTE_LIGHT) end
	-- 设置产生衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理函数（特殊召唤衍生物）
function c69868555.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，以及此卡是否仍在场上，若不满足则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 再次检查是否可以特殊召唤该衍生物，若不能则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,69868556,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_DRAGON,ATTRIBUTE_LIGHT) then return end
	-- 创建「巨龙衍生物」卡片实例
	local token=Duel.CreateToken(tp,69868556)
	-- 将衍生物以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤手卡或场上表侧表示的、可以作为cost送去墓地的7·8星龙族怪兽
function c69868555.thcostfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and c:IsAbleToGraveAsCost()
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 效果③的发动代价（Cost）处理函数
function c69868555.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可送去墓地的7·8星龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69868555.thcostfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡或场上1只7·8星的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c69868555.thcostfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果③的发动准备与目标确认函数
function c69868555.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将此卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理函数（此卡加入手卡）
function c69868555.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地的此卡加入手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的此卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end
