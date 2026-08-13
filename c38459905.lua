--F.A.シェイクダウン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的表示形式变更。那之后，选场上1张卡破坏。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「方程式运动员」怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c38459905.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的表示形式变更。那之后，选场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,38459905)
	e1:SetTarget(c38459905.target)
	e1:SetOperation(c38459905.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己主要阶段把墓地的这张卡除外，以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「方程式运动员」怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,38459906)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动；aux.exccon比较当前回合与卡的送墓回合，若同一回合则条件不满足，无法发动。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：将墓地中的这张卡除外；aux.bfgcost作为代价函数，在发动时若此卡可除外则将其除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38459905.sptg)
	e2:SetOperation(c38459905.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果的对象筛选条件：选择自己场上表侧表示、卡名含‘方程式运动员’字段、且当前能够变更表示形式的怪兽。
function c38459905.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107) and c:IsCanChangePosition()
end
-- ①效果的发动目标处理：确认自己场上有满足条件的‘方程式运动员’怪兽可选；发动时选择1只该怪兽为对象，并设置后续处理信息：变更该怪兽的表示形式，且之后破坏场上1张卡（破坏对象在效果处理时选择）。
function c38459905.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c38459905.filter(chkc) end
	-- 发动合法性检查：确认自己场上存在至少1只满足条件的‘方程式运动员’怪兽可作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c38459905.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示提示：请选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只满足条件的‘方程式运动员’怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c38459905.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本效果将变更对象怪兽的表示形式（CATEGORY_POSITION），对象为已选择的g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置操作信息：本效果还将破坏场上1张卡（CATEGORY_DESTROY），破坏对象在处理时选择，范围是双方场上。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end
-- ①效果处理：若对象仍与该效果关联，则对其变更表示形式；若变更成功，则从场上（除本卡外）选择1张卡破坏；使用BreakEffect对应原文‘那之后’。
function c38459905.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 判断对象是否仍与该效果关联，并尝试变更其表示形式；若变更成功（返回值非0）则继续处理后续破坏。
	if tc and tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
		-- 获取场上全部卡（不包含本卡）作为可能被破坏的候选集合。
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		if g:GetCount()==0 then return end
		-- 中断效果处理，使破坏的处理与表示形式变更分离，对应原文‘那之后’。
		Duel.BreakEffect()
		-- 显示‘请选择要破坏的卡’的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将玩家选择的卡以效果原因破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 定义②效果中要破坏的卡的条件：表侧表示，且将其破坏后自己场上仍有空余的怪兽区域以进行后续特殊召唤。
function c38459905.desfilter(c,tp)
	-- 对象必须是表侧表示，且在它被破坏后自己仍有至少1个可用怪兽区（保证后续特殊召唤有格子）。
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
-- 定义可特殊召唤的怪兽条件：卡组中的‘方程式运动员’字段怪兽，且能够被当前效果特殊召唤（满足召唤条件和苏生限制）。
function c38459905.spfilter(c,e,tp)
	return c:IsSetCard(0x107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动处理：确认场上存在可作为破坏对象的表侧表示卡（且破坏后有空位），同时卡组存在可特殊召唤的‘方程式运动员’怪兽；发动时选择1张表侧表示的卡作为对象，并设置操作信息。
function c38459905.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c38459905.desfilter(chkc,tp) end
	-- 发动合法性检查：确认自己场上存在至少1张表侧表示、且破坏后能留出怪兽区的卡作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c38459905.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		-- 同时确认卡组中存在至少1只满足条件的‘方程式运动员’怪兽，两者都满足才可发动。
		and Duel.IsExistingMatchingCard(c38459905.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 显示‘请选择要破坏的卡’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张满足条件的表侧表示的卡作为②效果的对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c38459905.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息：本效果将破坏对象怪兽（CATEGORY_DESTROY），对象为已选择的g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本效果将从卡组特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON），对象在处理时选择，来源为卡组，归属为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若对象仍与该效果关联且被成功破坏，且自己场上有空余怪兽区，则从卡组选择1只‘方程式运动员’怪兽表侧表示特殊召唤。
function c38459905.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的要破坏的卡。
	local tc=Duel.GetFirstTarget()
	-- 如果对象仍与该效果关联，且以效果原因将其破坏成功，则继续处理特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 处理时再次确认自己场上有可用的怪兽区，若没有则无法进行特殊召唤，直接结束。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 显示‘请选择要特殊召唤的卡’的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足条件的‘方程式运动员’怪兽，准备特殊召唤。
		local g=Duel.SelectMatchingCard(tp,c38459905.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
