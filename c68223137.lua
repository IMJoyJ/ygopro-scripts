--ワンクリウェイ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己或者对方的墓地1只连接1怪兽为对象才能发动。那只怪兽回到持有者的额外卡组或在持有者场上特殊召唤。
function c68223137.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己或者对方的墓地1只连接1怪兽为对象才能发动。那只怪兽回到持有者的额外卡组或在持有者场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,68223137+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c68223137.target)
	e1:SetOperation(c68223137.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己或对方墓地中可以回到额外卡组或可以特殊召唤的连接1怪兽
function c68223137.filter(c,e,tp)
	local p=c:GetControler()
	-- 判定卡片是否为连接1怪兽，且满足“能回到额外卡组”或“持有者场上有空位且能特殊召唤”其中之一
	return c:IsLink(1) and (c:IsAbleToExtra() or Duel.GetLocationCount(p,LOCATION_MZONE,tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p))
end
-- 效果发动时的目标选择与合法性检查函数
function c68223137.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c68223137.filter(chkc,e,tp) end
	-- 检查双方墓地是否存在至少1只满足条件的连接1怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c68223137.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要回到卡组或特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(68223137,0))  --"请选择要回到卡组或特殊召唤的怪兽"
	-- 选择双方墓地中1只满足条件的连接1怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68223137.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
end
-- 效果处理函数：将作为对象的怪兽回到额外卡组或在持有者场上特殊召唤
function c68223137.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 检查是否受到“王家长眠之谷”的影响，若受影响则使该效果无效
	if aux.NecroValleyNegateCheck(tc) then return end
	local p=tc:GetControler()
	-- 获取该怪兽持有者场上的可用怪兽区域空格数
	local ft=Duel.GetLocationCount(p,LOCATION_MZONE,tp)
	-- 如果该怪兽能回到额外卡组，且满足以下条件之一（不能特殊召唤、持有者场上没有空位、或者玩家主动选择“回到额外卡组”），则执行回到额外卡组的处理
	if tc:IsAbleToExtra() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p) or ft<=0 or Duel.SelectOption(tp,aux.Stringid(68223137,1),1152)==0) then  --"回到额外卡组"
		-- 将目标怪兽送回持有者的额外卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	else
		-- 将目标怪兽在持有者场上以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP)
	end
end
