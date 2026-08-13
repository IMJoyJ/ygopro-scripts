--閃刀術式－シザーズクロス
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以自己墓地1只4星「闪刀姬」怪兽为对象才能发动。那只怪兽加入手卡。自己墓地有魔法卡3张以上存在的场合，也能不加入手卡特殊召唤。
function c46271408.initial_effect(c)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合，以自己墓地1只4星「闪刀姬」怪兽为对象才能发动。那只怪兽加入手卡。自己墓地有魔法卡3张以上存在的场合，也能不加入手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c46271408.condition)
	e1:SetTarget(c46271408.target)
	e1:SetOperation(c46271408.activate)
	c:RegisterEffect(e1)
end
-- 定义cfilter过滤函数：判断卡片是否处于主要怪兽区域（区域序号<5），用于后续检测自己主要怪兽区域是否存在怪兽。
function c46271408.cfilter(c)
	return c:GetSequence()<5
end
-- 定义thfilter过滤函数：筛选自己墓地中4星且属于「闪刀姬」系列的怪兽，并且该怪兽可以加入手卡，或在满足条件时可以被特殊召唤。
function c46271408.thfilter(c,e,tp,spchk)
	return c:IsSetCard(0x1115) and c:IsLevel(4) and (c:IsAbleToHand() or (spchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 定义发动条件函数condition：检查自己主要怪兽区域没有怪兽存在，即不存在满足cfilter条件的卡。
function c46271408.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回不存在位于主要怪兽区域的卡（用cfilter过滤），从而满足“自己的主要怪兽区域没有怪兽存在”的发动条件。
	return not Duel.IsExistingMatchingCard(c46271408.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义效果发动时的目标选择函数target：判断能否选择墓地符合条件的「闪刀姬」怪兽为对象，并让玩家选择1张对象。
function c46271408.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算spchk第一个条件：自己主要怪兽区域是否存在可用空格（有空格才能特殊召唤）。
	local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 计算spchk第二个条件：自己墓地中魔法卡数量是否达到3张以上。
		and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46271408.thfilter(chkc,e,tp,spchk) end
	-- 在效果发动时（chk==0）检查墓地中是否存在至少1只满足thfilter条件的「闪刀姬」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c46271408.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,spchk) end
	-- 向玩家发送选择提示，提示信息为“请选择要加入手牌的卡”（用于选择墓地的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合thfilter条件的4星「闪刀姬」怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c46271408.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,spchk)
end
-- 定义效果处理时的操作函数activate：根据墓地魔法卡数量、自己场上空位以及玩家的选择，决定将对象怪兽特殊召唤还是加入手卡。
function c46271408.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时连锁上的对象卡（之前选择的目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 进行王家长眠之谷的效果检查：若对象卡受其影响导致本应无效，则直接终止本次效果处理。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 判断自己墓地中魔法卡数量是否达到3张以上（特殊召唤的追加条件之一）。
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
			-- 判断自己主要怪兽区域是否有空位（特殊召唤的追加条件之一）。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 当墓地魔法卡≥3、有空格且对象可以特殊召唤时，弹出选项让玩家选择“加入手卡”或“特殊召唤”；若选择第二项（返回1）则执行特殊召唤。
			and Duel.SelectOption(tp,1190,1152)==1 then
			-- 将对象怪兽以表侧表示特殊召唤到自己场上（使用效果特殊召唤，不check苏生限制）。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将对象怪兽加入持有者的手卡（效果处理为加入手卡时的操作）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
