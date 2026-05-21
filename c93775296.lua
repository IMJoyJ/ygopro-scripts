--リバース・リユース
-- 效果：
-- ①：以自己墓地最多2只反转怪兽为对象才能发动。那些怪兽表侧守备表示或者里侧守备表示在对方场上特殊召唤。
function c93775296.initial_effect(c)
	-- ①：以自己墓地最多2只反转怪兽为对象才能发动。那些怪兽表侧守备表示或者里侧守备表示在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c93775296.target)
	e1:SetOperation(c93775296.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以特殊召唤到对方场上守备表示的反转怪兽。
function c93775296.filter(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE,1-tp)
end
-- 效果发动时的对象选择与合法性检测。
function c93775296.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93775296.filter(chkc,e,tp) end
	-- 发动条件检测：对方场上必须有至少1个空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 发动条件检测：自己墓地必须存在至少1只可以特殊召唤的反转怪兽。
		and Duel.IsExistingTarget(c93775296.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取对方场上空余的怪兽区域数量。
	local ct=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1到ct只（最多2只）满足条件的反转怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c93775296.filter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 设置特殊召唤的操作信息，用于后续连锁处理的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，处理特殊召唤的逻辑。
function c93775296.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取作为效果对象的卡片中，在效果处理时仍然存活且关系成立的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>ft or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	-- 将目标怪兽以守备表示（表侧或里侧）特殊召唤到对方场上。
	Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_DEFENSE)
end
