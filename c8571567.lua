--BF－嵐砂のシャマール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地才能发动。从卡组把1张「黑羽之旋风」在自己场上表侧表示放置。
-- ②：这张卡在墓地存在的状态，自己场上有「黑羽」同调怪兽或「黑翼龙」特殊召唤的场合，把这张卡除外，以自己墓地1只「黑羽」怪兽为对象才能发动。那只怪兽加入手卡。那之后，自己受到700伤害。
function c8571567.initial_effect(c)
	-- 注册卡片「黑翼龙」的卡名，表明这张卡的效果记有该卡名。
	aux.AddCodeList(c,9012916)
	-- 注册一个监听此卡送入墓地状态的效果，用于后续验证其在墓地发动的合法性。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：把手卡·场上的这张卡送去墓地才能发动。从卡组把1张「黑羽之旋风」在自己场上表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8571567,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,8571567)
	e1:SetCost(c8571567.tfcost)
	e1:SetTarget(c8571567.tftg)
	e1:SetOperation(c8571567.tfop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上有「黑羽」同调怪兽或「黑翼龙」特殊召唤的场合，把这张卡除外，以自己墓地1只「黑羽」怪兽为对象才能发动。那只怪兽加入手卡。那之后，自己受到700伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8571567,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,8571568)
	e2:SetLabelObject(e0)
	e2:SetCondition(c8571567.thcon)
	-- 设置效果②的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c8571567.thtg)
	e2:SetOperation(c8571567.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价函数：检查并把手卡·场上的这张卡送去墓地。
function c8571567.tfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为发动代价的这张卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果①的卡片过滤函数：检索卡组中未被禁止且在场上唯一的「黑羽之旋风」。
function c8571567.tffilter(c,tp)
	return c:IsCode(7602800)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果①的发动条件与目标选择函数。
function c8571567.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己卡组中是否存在至少1张满足条件的「黑羽之旋风」。
		and Duel.IsExistingMatchingCard(c8571567.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果①的效果处理函数。
function c8571567.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的魔法与陷阱区域是否已无空位，若无则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1张满足条件的「黑羽之旋风」。
	local tc=Duel.SelectMatchingCard(tp,c8571567.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选择的卡片在自己的魔法与陷阱区域表侧表示放置。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 效果②的特殊召唤怪兽过滤函数：检查是否为自己场上表侧表示的「黑羽」同调怪兽或「黑翼龙」。
function c8571567.cfilter(c,tp,se)
	return c:IsFaceup() and ((c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO)) or c:IsCode(9012916))
		and c:IsControler(tp) and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②的发动条件函数：检查特殊召唤的怪兽中是否存在满足条件的怪兽。
function c8571567.thcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c8571567.cfilter,1,nil,tp,se)
end
-- 效果②的回收目标过滤函数：检查自己墓地中可加入手卡的「黑羽」怪兽。
function c8571567.thfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动条件与目标选择函数。
function c8571567.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c8571567.thfilter(chkc) end
	-- 检查自己墓地中是否存在至少1只除这张卡以外的、满足条件的「黑羽」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c8571567.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中1只满足条件的「黑羽」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c8571567.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理信息：给与自己700点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,700)
end
-- 效果②的效果处理函数。
function c8571567.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的发动对象。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍与效果相关，则将其加入持有者的手牌，并检查是否成功加入。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续的伤害处理与加入手牌不视为同时进行。
		Duel.BreakEffect()
		-- 给与自己700点效果伤害。
		Duel.Damage(tp,700,REASON_EFFECT)
	end
end
