--黒魔族復活の棺
-- 效果：
-- ①：对方对怪兽的召唤·特殊召唤成功时，以那1只怪兽和自己场上1只魔法师族怪兽为对象才能发动。那2只怪兽送去墓地。那之后，可以从自己的卡组·墓地选1只魔法师族·暗属性怪兽特殊召唤。
function c9287078.initial_effect(c)
	-- ①：对方对怪兽的召唤·特殊召唤成功时，以那1只怪兽和自己场上1只魔法师族怪兽为对象才能发动。那2只怪兽送去墓地。那之后，可以从自己的卡组·墓地选1只魔法师族·暗属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c9287078.target)
	e1:SetOperation(c9287078.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤对方召唤·特殊召唤成功且可以成为效果对象的怪兽，并且自己场上存在可以作为对象的魔法师族怪兽
function c9287078.filter1(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e)
		-- 判断自己场上是否存在除该怪兽以外的、可以成为效果对象的魔法师族怪兽
		and Duel.IsExistingTarget(c9287078.filter2,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤自己场上表侧表示的魔法师族怪兽
function c9287078.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 效果发动时的对象选择与操作信息设置
function c9287078.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:IsExists(c9287078.filter1,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g1=eg:FilterSelect(tp,c9287078.filter1,1,1,nil,e,tp)
	-- 将对方召唤·特殊召唤的怪兽设为效果处理的对象
	Duel.SetTargetCard(g1)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只表侧表示的魔法师族怪兽作为对象
	local g2=Duel.SelectTarget(tp,c9287078.filter2,tp,LOCATION_MZONE,0,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 设置效果处理信息为：将这2只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
end
-- 过滤卡组·墓地中可以特殊召唤的魔法师族·暗属性怪兽
function c9287078.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的核心逻辑
function c9287078.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 判断2只对象怪兽是否成功送去墓地且存在于墓地
	if g:GetCount()==2 and Duel.SendtoGrave(g,REASON_EFFECT)==2 and g:IsExists(Card.IsLocation,2,nil,LOCATION_GRAVE) then
		-- 若自己场上没有空余的怪兽区域，则不进行后续特殊召唤处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取自己卡组·墓地中满足特殊召唤条件且不受王家长眠之谷影响的魔法师族·暗属性怪兽
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c9287078.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
		-- 若存在可选怪兽，询问玩家是否进行特殊召唤
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(9287078,0)) then  --"是否从自己的卡组·墓地选1只魔法师族·暗属性怪兽特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地同时进行（造成错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
