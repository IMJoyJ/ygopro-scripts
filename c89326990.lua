--SRオハジキッド
-- 效果：
-- ①：这张卡召唤成功时，以自己或者对方的墓地1只调整为对象才能发动。那只怪兽在自己场上特殊召唤，只用那只怪兽和这张卡为素材把1只风属性同调怪兽同调召唤。
function c89326990.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己或者对方的墓地1只调整为对象才能发动。那只怪兽在自己场上特殊召唤，只用那只怪兽和这张卡为素材把1只风属性同调怪兽同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89326990,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c89326990.target)
	e1:SetOperation(c89326990.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：双方墓地可特殊召唤的调整，且能与自身作为素材同调召唤风属性同调怪兽
function c89326990.filter(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在可以以指定怪兽为素材同调召唤的风属性同调怪兽
		and Duel.IsExistingMatchingCard(c89326990.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 过滤条件：风属性且能以指定素材进行同调召唤的怪兽
function c89326990.scfilter(c,mg)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsSynchroSummonable(nil,mg)
end
-- 发动效果处理：确认墓地目标合法性
function c89326990.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c89326990.filter(chkc,e,tp,e:GetHandler()) end
	-- 检查玩家是否能进行至少2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查怪兽区是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在满足条件的调整怪兽
		and Duel.IsExistingTarget(c89326990.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler()) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择双方墓地1只满足条件的调整怪兽作为对象
	local g=Duel.SelectTarget(tp,c89326990.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,e:GetHandler())
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤对象怪兽并用其和自身作为素材进行同调召唤
function c89326990.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 将对象怪兽表侧表示特殊召唤到自己场上，特殊召唤失败则结束
	if not tc:IsRelateToEffect(e) or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local mg=Group.FromCards(c,tc)
	-- 获取额外卡组中能以两只怪兽为素材同调召唤的风属性同调怪兽
	local g=Duel.GetMatchingGroup(c89326990.scfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以两只怪兽为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
