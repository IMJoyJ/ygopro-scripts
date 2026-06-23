--破械神王ヤマ
-- 效果：
-- 恶魔族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1只「破械」怪兽加入手卡。
-- ②：这张卡在墓地存在的状态，自己场上的卡被战斗·效果破坏的场合，把这张卡除外才能发动。从自己的手卡·墓地把1只恶魔族怪兽特殊召唤。那之后，可以把自己场上1张卡破坏。
function c24269961.initial_effect(c)
	-- 为卡片注册一个监听送入墓地事件的单次持续效果，用于验证卡片是否已进入墓地以满足效果发动条件
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 为卡片添加连接召唤手续，要求使用2只满足恶魔族种族条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FIEND),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1只「破械」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24269961,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,24269961)
	e1:SetTarget(c24269961.thtg)
	e1:SetOperation(c24269961.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的卡被战斗·效果破坏的场合，把这张卡除外才能发动。从自己的手卡·墓地把1只恶魔族怪兽特殊召唤。那之后，可以把自己场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24269961,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,24269962)
	e2:SetCondition(c24269961.spcon)
	-- 设置效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c24269961.sptg)
	e2:SetOperation(c24269961.spop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
end
-- 定义过滤条件：满足「破械」卡组编号且为怪兽类型且可以加入手牌的卡
function c24269961.thfilter(c)
	return c:IsSetCard(0x130) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果发动时的检查条件：确认自己卡组或墓地是否存在满足条件的卡
function c24269961.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查条件：确认自己卡组或墓地是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c24269961.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：将1张满足条件的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：选择满足条件的卡加入手牌并确认对方查看
function c24269961.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24269961.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义过滤条件：满足破坏原因来自战斗或效果且在场上被破坏的卡
function c24269961.cfilter(c,tp,se)
	return c:GetPreviousControler()==tp
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 设置效果发动条件：确认被破坏的卡中存在满足条件的卡且不包含此卡本身
function c24269961.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c24269961.cfilter,1,nil,tp,se) and not eg:IsContains(e:GetHandler())
end
-- 定义过滤条件：满足恶魔族种族且可以特殊召唤的卡
function c24269961.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的检查条件：确认自己手牌或墓地是否存在满足条件的卡
function c24269961.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查条件：确认自己场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查条件：确认自己手牌或墓地是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(c24269961.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁操作信息：将1张满足条件的卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数：选择满足条件的卡特殊召唤，并可选择破坏自己场上的1张卡
function c24269961.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查条件：确认自己场上存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24269961.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 执行特殊召唤操作并判断是否成功
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取自己场上的所有卡作为可破坏对象
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
		-- 询问玩家是否选择破坏自己场上的1张卡
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(24269961,2)) then  --"是否把自己场上1张卡破坏？"
			-- 中断当前效果处理，使后续效果处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local deg=dg:Select(tp,1,1,nil)
			-- 显示被选为破坏对象的卡
			Duel.HintSelection(deg)
			-- 将选中的卡破坏
			Duel.Destroy(deg,REASON_EFFECT)
		end
	end
end
