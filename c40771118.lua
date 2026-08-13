--死の宣告
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以最多有自己场上的「通灵盘」以及「死之信息」卡数量的恶魔族怪兽为对象才能发动。那些怪兽加入手卡。
-- ②：把魔法与陷阱区域的这张卡送去墓地才能发动。从自己的手卡·卡组·墓地选1张「死之信息」卡当作「通灵盘」的效果在自己的魔法与陷阱区域出现。
function c40771118.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从自己墓地的怪兽以及除外的自己怪兽之中以最多有自己场上的「通灵盘」以及「死之信息」卡数量的恶魔族怪兽为对象才能发动。那些怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40771118,0))  --"回收怪兽"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,40771118)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetTarget(c40771118.thtg)
	e2:SetOperation(c40771118.thop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的这张卡送去墓地才能发动。从自己的手卡·卡组·墓地选1张「死之信息」卡当作「通灵盘」的效果在自己的魔法与陷阱区域出现。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40771118,1))  --"让「死之信息」出现"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,40771118)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCost(c40771118.plcost)
	e3:SetTarget(c40771118.pltg)
	e3:SetOperation(c40771118.plop)
	c:RegisterEffect(e3)
end
-- 定义①效果的对象筛选条件：选择自己的墓地怪兽或表侧表示的除外怪兽，且必须为恶魔族、能够加入手卡。
function c40771118.thfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- 定义统计场上通灵盘/死之信息卡片用过滤：表侧表示且卡名是通灵盘或属于死之信息系列。
function c40771118.cfilter(c)
	return c:IsFaceup() and (c:IsCode(94212438) or c:IsSetCard(0x1c))
end
-- ①效果的目标函数：判定发动条件、计算可选数量上限、选择对象并登记操作信息。
function c40771118.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c40771118.thfilter(chkc) end
	-- 发动时点检查：自己墓地或除外区是否存在至少1只符合条件的恶魔族怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c40771118.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 获取自己场上表侧表示的通灵盘以及死之信息卡，用于计算可选对象的上限数量。
	local cg=Duel.GetMatchingGroup(c40771118.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local ct=cg:GetClassCount(Card.GetCode)
	-- 给玩家显示“请选择要加入手牌的卡”的选择提示，供后续选择框使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地或除外区选择1到ct张（ct为场上通灵盘与死之信息的卡名种类数）符合条件的恶魔族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c40771118.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil)
	-- 设置连锁操作信息：本次效果将对象卡加入手牌，供其他卡检测该效果类别。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- ①效果的处理函数：取出连锁上的对象卡，过滤出仍然与效果关联的卡，将其加入持有者手牌。
function c40771118.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得发动时选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将过滤后仍与效果关联的对象卡加入其持有者的手牌，原因为效果处理。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- ②效果的代价函数：确认这张死之宣告在魔法与陷阱区域且效果适用中，并将其送入墓地作为发动代价。
function c40771118.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将这张死之宣告自身送去墓地，作为效果的发动代价。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 选择“死之信息”卡的过滤条件：必须是死之信息系列；若适用暗黑圣域且条件满足则可特殊召唤，否则需魔陷区有空位且不为禁止卡。
function c40771118.plfilter(c,tp,mc)
	if not c:IsSetCard(0x1c) then return false end
	-- 判断是否适用暗黑圣域的效果，以及自己主要怪兽区是否有空位可供特殊召唤。
	if Duel.IsPlayerAffectedByEffect(tp,16625614) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己能否将这张死之信息卡作为暗黑圣域定义的通常怪兽（恶魔族·暗·1星·攻/守0）特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp,SUMMON_VALUE_DARK_SANCTUARY) then return true end
	-- 获取自己魔法与陷阱区的可用空格数，用于后续判断能否将死之信息卡放置到魔陷区。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if mc:IsLocation(LOCATION_SZONE) then ft=ft+1 end
	return ft>0 and not c:IsForbidden()
end
-- ②效果的发动目标函数：检查自己手牌·卡组·墓地是否存在符合条件的死之信息卡。
function c40771118.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：若手牌·卡组·墓地存在至少1张满足plfilter的死之信息卡，则②效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c40771118.plfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp,e:GetHandler()) end
end
-- ②效果的处理函数：选择1张死之信息卡，根据暗黑圣域是否适用及玩家选择，将其特殊召唤为怪兽或放置到魔陷区。
function c40771118.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示“请选择要出现的卡”的选择提示，用于从手牌·卡组·墓地中选择死之信息卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40771118,2))  --"请选择要出现的卡"
	-- 从自己手牌·卡组·墓地中选1张符合条件的死之信息卡。
	local g=Duel.SelectMatchingCard(tp,c40771118.plfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp,c)
	local tc=g:GetFirst()
	-- 判断是否满足暗黑圣域的特殊召唤条件：适用暗黑圣域且主要怪兽区有空位。
	if tc and Duel.IsPlayerAffectedByEffect(tp,16625614) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断能否将所选的死之信息卡作为暗黑圣域规定的通常怪兽特殊召唤（依据暗黑圣域的特殊召唤参数）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp,SUMMON_VALUE_DARK_SANCTUARY)
		-- 询问玩家是否要将这张死之信息卡作为通常怪兽特殊召唤（暗黑圣域的效果）。
		and Duel.SelectYesNo(tp,aux.Stringid(16625614,0)) then  --"是否作为通常怪兽特殊召唤？"
		tc:AddMonsterAttribute(TYPE_NORMAL,ATTRIBUTE_DARK,RACE_FIEND,1,0,0)
		-- 将所选的死之信息卡以暗黑圣域的特殊召唤方式，作为通常怪兽正面表示特殊召唤（加入特殊召唤连锁步骤）。
		Duel.SpecialSummonStep(tc,SUMMON_VALUE_DARK_SANCTUARY,tp,tp,true,false,POS_FACEUP)
		-- 这个效果特殊召唤的卡不受「通灵盘」以外的卡的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c16625614.efilter)
		e1:SetReset(RESET_EVENT+0x47c0000)
		tc:RegisterEffect(e1)
		-- 不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+0x47c0000)
		tc:RegisterEffect(e2)
		-- 完成整个特殊召唤处理，统一结算所有SpecialSummonStep步骤。
		Duel.SpecialSummonComplete()
	-- 若不满足暗黑圣域特殊召唤条件（或不选择特召），则判断魔法与陷阱区是否有空位；有空位时执行放置处理。
	elseif tc and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 将所选的死之信息卡移动到自己的魔法与陷阱区并正面表示放置，同时使其效果适用，即当作「通灵盘」的效果出现。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
