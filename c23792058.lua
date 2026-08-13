--SRヘキサソーサー
-- 效果：
-- ←6 【灵摆】 6→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只风属性同调怪兽为对象才能发动。那只怪兽回到额外卡组。
-- 【怪兽效果】
-- ①：这张卡的战斗发生的战斗伤害由双方玩家承受。
-- ②：这张卡的战斗发生的双方的战斗伤害变成一半。
-- ③：这张卡在灵摆区域被破坏的场合才能发动。从自己的额外卡组把1只表侧表示的「疾行机人」灵摆怪兽特殊召唤。
function c23792058.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽共通属性（可进行灵摆召唤、灵摆刻度发动等）。
	aux.EnablePendulumAttribute(c)
	-- ←6 【灵摆】 6→ 这个卡名的灵摆效果1回合只能使用1次。①：从自己墓地的怪兽以及除外的自己怪兽之中以1只风属性同调怪兽为对象才能发动。那只怪兽回到额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23792058,0))
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,23792058)
	e1:SetTarget(c23792058.tdtg)
	e1:SetOperation(c23792058.tdop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】①：这张卡的战斗发生的战斗伤害由双方玩家承受。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_BOTH_BATTLE_DAMAGE)
	c:RegisterEffect(e0)
	-- 【怪兽效果】②：这张卡的战斗发生的双方的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e2:SetValue(HALF_DAMAGE)
	c:RegisterEffect(e2)
	-- 【怪兽效果】③：这张卡在灵摆区域被破坏的场合才能发动。从自己的额外卡组把1只表侧表示的「疾行机人」灵摆怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c23792058.spcon)
	e3:SetTarget(c23792058.sptg)
	e3:SetOperation(c23792058.spop)
	c:RegisterEffect(e3)
end
-- 定义灵摆效果的可选对象：风属性同调怪兽，能返回额外卡组，且位于自己墓地或除外的表侧表示怪兽。
function c23792058.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 灵摆效果的发动时点处理：确认存在可取对象后，让玩家从自己墓地/除外区选择1只符合条件的风属性同调怪兽作为对象，并设定回额外卡组的操作信息。
function c23792058.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c23792058.tdfilter(chkc) end
	-- 效果发动合法性检查：自己墓地或除外区是否存在至少1只满足过滤条件的风属性同调怪兽。
	if chk==0 then return Duel.IsExistingTarget(c23792058.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 弹出/写入选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 令玩家从自己墓地/除外区选择1张满足条件的怪兽卡作为效果对象。
	local g=Duel.SelectTarget(tp,c23792058.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 登记本次处理会将对象卡返回卡组的操作信息（回卡组分类，1张）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 灵摆效果的结算：获取对象卡，若其仍与该效果有关联，则将其返回持有者卡组并洗牌。
function c23792058.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因返回持有者卡组，并触发洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 怪兽效果③的发动条件：这张卡在灵摆区域被破坏的场合（破坏前位于灵摆区域）。
function c23792058.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
-- 特殊召唤对象的过滤条件：额外卡组表侧表示的「疾行机人」灵摆怪兽，满足特殊召唤限制，且我方额外怪兽区域有空位可放置。
function c23792058.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x2016)
		-- 该怪兽能够被特殊召唤，且我方有足够的额外怪兽区域空格可供特殊召唤。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 特殊召唤效果的目标处理：确认额外卡组存在至少1只可特殊召唤的表侧「疾行机人」灵摆怪兽，并登记从额外卡组特殊召唤1只的操作信息。
function c23792058.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：额外卡组是否存在至少1只满足特殊召唤条件的「疾行机人」表侧灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c23792058.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记本次处理会从额外卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果结算：从额外卡组选出所有符合条件的「疾行机人」表侧灵摆怪兽，再由玩家选择1只以表侧攻击表示特殊召唤。
function c23792058.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取额外卡组中所有满足特殊召唤条件的表侧「疾行机人」灵摆怪兽。
	local g=Duel.GetMatchingGroup(c23792058.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
