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
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只风属性同调怪兽为对象才能发动。那只怪兽回到额外卡组。
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
	-- ①：这张卡的战斗发生的战斗伤害由双方玩家承受。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_BOTH_BATTLE_DAMAGE)
	c:RegisterEffect(e0)
	-- ②：这张卡的战斗发生的双方的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e2:SetValue(HALF_DAMAGE)
	c:RegisterEffect(e2)
	-- ③：这张卡在灵摆区域被破坏的场合才能发动。从自己的额外卡组把1只表侧表示的「疾行机人」灵摆怪兽特殊召唤。
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
-- 过滤函数，用于筛选满足条件的风属性同调怪兽（存在于墓地或除外区）并可返回额外卡组
function c23792058.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 设置灵摆效果的目标选择函数，允许从墓地或除外区选择符合条件的风属性同调怪兽
function c23792058.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c23792058.tdfilter(chkc) end
	-- 检查是否满足灵摆效果的发动条件，即是否存在符合条件的风属性同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c23792058.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择符合条件的风属性同调怪兽作为目标
	local g=Duel.SelectTarget(tp,c23792058.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，表示将目标怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 执行灵摆效果的操作，将目标怪兽送回额外卡组
function c23792058.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送回玩家卡组顶部并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 判断该卡是否在灵摆区域被破坏
function c23792058.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
-- 过滤函数，用于筛选满足条件的「疾行机人」灵摆怪兽（表侧表示、可特殊召唤、有召唤空间）
function c23792058.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x2016)
		-- 检查目标灵摆怪兽是否可以特殊召唤且场上存在召唤空间
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置特殊召唤效果的目标选择函数，从额外卡组中选择符合条件的灵摆怪兽
function c23792058.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤效果的发动条件，即是否存在符合条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23792058.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从额外卡组特殊召唤1只灵摆怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤效果的操作，从额外卡组特殊召唤符合条件的灵摆怪兽
function c23792058.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取满足特殊召唤条件的灵摆怪兽组
	local g=Duel.GetMatchingGroup(c23792058.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的灵摆怪兽以特殊召唤方式送至场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
