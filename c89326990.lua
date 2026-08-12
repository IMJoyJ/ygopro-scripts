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
-- 过滤墓地中可以特殊召唤，且能与这张卡作为素材同调召唤额外卡组中风属性同调怪兽的调整怪兽
function c89326990.filter(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在可以使用当前怪兽组合作为素材进行同调召唤的怪兽
		and Duel.IsExistingMatchingCard(c89326990.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 过滤额外卡组中可以使用指定素材组进行同调召唤的风属性同调怪兽
function c89326990.scfilter(c,mg)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsSynchroSummonable(nil,mg)
end
-- 效果发动时的目标选择与可行性检查
function c89326990.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c89326990.filter(chkc,e,tp,e:GetHandler()) end
	-- 检查玩家是否能进行2次特殊召唤（特召墓地怪兽与同调召唤）
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在至少1只满足条件的调整怪兽作为效果对象
		and Duel.IsExistingTarget(c89326990.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择双方墓地中1只满足条件的调整怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89326990.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,e:GetHandler())
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将目标怪兽特殊召唤并进行同调召唤
function c89326990.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local c=e:GetHandler()
	-- 获取发动时选择的墓地调整怪兽
	local tc=Duel.GetFirstTarget()
	-- 将目标怪兽在自己场上表侧表示特殊召唤，若特殊召唤失败则结束处理
	if not tc:IsRelateToEffect(e) or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if not c:IsRelateToEffect(e) then return end
	local mg=Group.FromCards(c,tc)
	-- 获取额外卡组中仅以这两张卡为素材可以进行同调召唤的风属性同调怪兽
	local g=Duel.GetMatchingGroup(c89326990.scfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要同调召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 仅使用这两张卡作为素材，对选定的风属性同调怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
