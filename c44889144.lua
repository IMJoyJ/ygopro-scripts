--リブロマンサー・インターフェア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方把魔法·陷阱·怪兽的效果发动时，以自己场上1只「书灵师」仪式怪兽为对象才能发动。那只怪兽回到持有者手卡，那个发动的效果无效。那之后，可以从自己的手卡·墓地选1只「书灵师」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果，创建一个连锁发动的魔法卡效果
function s.initial_effect(c)
	-- ①：对方把魔法·陷阱·怪兽的效果发动时，以自己场上1只「书灵师」仪式怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.f2hcon)
	e1:SetTarget(s.f2htg)
	e1:SetOperation(s.f2hop)
	c:RegisterEffect(e1)
end
-- 判断是否为对方发动效果且该效果可以被无效
function s.f2hcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动效果且该效果可以被无效
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 过滤满足条件的「书灵师」仪式怪兽
function s.f2hfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x17c) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标，选择1只满足条件的场上怪兽
function s.f2htg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.f2hfilter(chkc) end
	-- 检查是否有满足条件的场上怪兽
	if chk==0 then return Duel.IsExistingTarget(s.f2hfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1只满足条件的场上怪兽作为目标
	local g=Duel.SelectTarget(tp,s.f2hfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置将目标怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	-- 设置使对方效果无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 过滤满足条件的「书灵师」怪兽用于特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果，将目标怪兽送回手牌并使效果无效，然后询问是否特殊召唤
function s.f2hop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 目标怪兽存在于场上且成功送回手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		-- 目标怪兽在手牌且对方效果被无效
		and tc:IsLocation(LOCATION_HAND) and Duel.NegateEffect(ev)
		-- 己方场上存在空位可用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 己方手牌或墓地存在满足条件的「书灵师」怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选1只「书灵师」怪兽特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只满足条件的「书灵师」怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #sg>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
