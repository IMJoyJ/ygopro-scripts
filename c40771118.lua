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
	-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以最多有自己场上的「通灵盘」以及「死之信息」卡数量的恶魔族怪兽为对象才能发动。那些怪兽加入手卡。
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
-- 过滤函数，用于判断目标怪兽是否满足加入手牌的条件（墓地或表侧表示，恶魔族，可加入手牌）
function c40771118.thfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- 过滤函数，用于判断场上是否存在「通灵盘」或「死之信息」卡
function c40771118.cfilter(c)
	return c:IsFaceup() and (c:IsCode(94212438) or c:IsSetCard(0x1c))
end
-- 效果处理时的判定函数，检查是否有满足条件的怪兽可作为对象
function c40771118.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c40771118.thfilter(chkc) end
	-- 检查是否有满足条件的怪兽可作为对象
	if chk==0 then return Duel.IsExistingTarget(c40771118.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 获取场上「通灵盘」和「死之信息」卡的集合
	local cg=Duel.GetMatchingGroup(c40771118.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local ct=cg:GetClassCount(Card.GetCode)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c40771118.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil)
	-- 设置效果操作信息，表示将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果处理函数，将符合条件的怪兽加入手牌
function c40771118.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的怪兽加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- 效果处理函数，支付将此卡送去墓地的费用
function c40771118.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将此卡送去墓地作为费用
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤函数，用于判断是否可以将卡当作「通灵盘」使用
function c40771118.plfilter(c,tp,mc)
	if not c:IsSetCard(0x1c) then return false end
	-- 判断玩家是否受到「暗黑圣域」效果影响且场上存在空位
	if Duel.IsPlayerAffectedByEffect(tp,16625614) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤该卡为token怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp,SUMMON_VALUE_DARK_SANCTUARY) then return true end
	-- 获取玩家魔法与陷阱区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if mc:IsLocation(LOCATION_SZONE) then ft=ft+1 end
	return ft>0 and not c:IsForbidden()
end
-- 效果处理时的判定函数，检查是否有满足条件的「死之信息」卡可作为对象
function c40771118.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「死之信息」卡可作为对象
	if chk==0 then return Duel.IsExistingMatchingCard(c40771118.plfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp,e:GetHandler()) end
end
-- 效果处理函数，将符合条件的「死之信息」卡当作「通灵盘」使用
function c40771118.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要出现的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40771118,2))  --"请选择要出现的卡"
	-- 选择满足条件的「死之信息」卡作为对象
	local g=Duel.SelectMatchingCard(tp,c40771118.plfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp,c)
	local tc=g:GetFirst()
	-- 判断玩家是否受到「暗黑圣域」效果影响且场上存在空位
	if tc and Duel.IsPlayerAffectedByEffect(tp,16625614) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤该卡为token怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp,SUMMON_VALUE_DARK_SANCTUARY)
		-- 询问玩家是否将该卡作为通常怪兽特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(16625614,0)) then  --"是否作为通常怪兽特殊召唤？"
		tc:AddMonsterAttribute(TYPE_NORMAL,ATTRIBUTE_DARK,RACE_FIEND,1,0,0)
		-- 特殊召唤token怪兽
		Duel.SpecialSummonStep(tc,SUMMON_VALUE_DARK_SANCTUARY,tp,tp,true,false,POS_FACEUP)
		-- 为token怪兽设置免疫效果的属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c16625614.efilter)
		e1:SetReset(RESET_EVENT+0x47c0000)
		tc:RegisterEffect(e1)
		-- 为token怪兽设置忽略战斗目标的属性
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+0x47c0000)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	-- 判断是否可以将卡移动到魔法与陷阱区域
	elseif tc and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 将卡移动到魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
