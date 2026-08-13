--破械神王ヤマ
-- 效果：
-- 恶魔族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1只「破械」怪兽加入手卡。
-- ②：这张卡在墓地存在的状态，自己场上的卡被战斗·效果破坏的场合，把这张卡除外才能发动。从自己的手卡·墓地把1只恶魔族怪兽特殊召唤。那之后，可以把自己场上1张卡破坏。
function c24269961.initial_effect(c)
	-- 为这张卡注册一个“已在墓地”的标记检测效果，用于记录该卡进入墓地的事实，防止在同一个连锁中因重复判定而误触发②效果。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 为这张卡添加连接召唤手续：必须且只能用2只恶魔族怪兽作为连接素材来连接召唤。
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
	-- 设置②效果的发动代价：将此卡从墓地除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c24269961.sptg)
	e2:SetOperation(c24269961.spop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
end
-- 定义①效果的检索过滤条件：必须是「破械」字段的怪兽卡，并且能够加入手牌。
function c24269961.thfilter(c)
	return c:IsSetCard(0x130) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动时点检查：确认自己卡组·墓地存在至少1只满足检索条件的「破械」怪兽，并设定本次操作的信息为将1张卡加入手牌。
function c24269961.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性判定：自己卡组·墓地中是否存在至少1只符合条件的「破械」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24269961.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理时的操作信息：从卡组·墓地中选1张卡加入手牌，并记录检索范围。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的实际处理：从自己卡组·墓地选择1只「破械」怪兽加入手牌，并给对方确认。
function c24269961.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组·墓地选择1只满足thfilter条件且不受王家长眠之谷影响的「破械」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24269961.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果触发所需破坏卡的过滤条件：被破坏的卡之前控制者为己方、因战斗或效果破坏、之前位于场上，且破坏来源不是本效果自身（用于避免自己效果破坏自己场上的卡时误触发）。
function c24269961.cfilter(c,tp,se)
	return c:GetPreviousControler()==tp
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的发动条件：本连锁中有己方场上的卡被战斗或效果破坏，且破坏的卡中不包含这张卡自身（该卡在墓地时不会在eg中，实际恒为满足）。
function c24269961.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c24269961.cfilter,1,nil,tp,se) and not eg:IsContains(e:GetHandler())
end
-- 定义②效果特殊召唤的过滤条件：必须是恶魔族怪兽，并且能够被效果特殊召唤。
function c24269961.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时点检查：自己场上存在可用的怪兽区域，并且手牌·墓地中存在满足特殊召唤条件的恶魔族怪兽（排除此卡自身）。
function c24269961.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性判定：自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时合法性判定：手牌·墓地中是否存在至少1只符合条件的恶魔族怪兽，且将墓地中的此卡自身从候选对象中排除。
		and Duel.IsExistingMatchingCard(c24269961.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置效果处理时的操作信息：从手牌·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的实际处理：从自己手牌·墓地选择1只恶魔族怪兽特殊召唤，成功后再询问是否破坏自己场上1张卡，若选择是则进行破坏。
function c24269961.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有空余的怪兽区域，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手牌·墓地选择1只满足spfilter条件且不受王家长眠之谷影响的恶魔族怪兽进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24269961.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若成功选择了怪兽并特殊召唤上场，则继续执行后续可选破坏处理。
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取自己场上所有卡片（包括表侧和里侧）作为后续可选破坏的候选。
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
		-- 若自己场上有可破坏的卡，则询问是否发动“那之后”的破坏效果；玩家选择是才继续。
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(24269961,2)) then  --"是否把自己场上1张卡破坏？"
			-- 中断当前效果，使后续的破坏处理视为在不同时点进行，避免产生错误的时点联动。
			Duel.BreakEffect()
			-- 显示“请选择要破坏的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local deg=dg:Select(tp,1,1,nil)
			-- 向双方展示被选为破坏对象的卡，并标记该卡已作为对象。
			Duel.HintSelection(deg)
			-- 以效果破坏所选的目标卡片。
			Duel.Destroy(deg,REASON_EFFECT)
		end
	end
end
