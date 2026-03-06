--劫火の舟守 ゴースト・カロン
-- 效果：
-- 「劫火之舟守 幽鬼冥船夫」的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族怪兽不能特殊召唤。
-- ①：对方场上有怪兽存在，自己场上没有这张卡以外的怪兽存在的场合，以自己墓地1只融合怪兽为对象才能发动。墓地的那只怪兽和场上的这张卡除外，把持有和那2只的等级合计相同等级的1只龙族同调怪兽从额外卡组特殊召唤。
function c23379054.initial_effect(c)
	-- 效果原文内容：①：对方场上有怪兽存在，自己场上没有这张卡以外的怪兽存在的场合，以自己墓地1只融合怪兽为对象才能发动。墓地的那只怪兽和场上的这张卡除外，把持有和那2只的等级合计相同等级的1只龙族同调怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,23379054)
	e1:SetCondition(c23379054.condition)
	e1:SetCost(c23379054.cost)
	e1:SetTarget(c23379054.target)
	e1:SetOperation(c23379054.operation)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在1回合内特殊召唤的龙族怪兽数量，以限制效果使用次数。
	Duel.AddCustomActivityCounter(23379054,ACTIVITY_SPSUMMON,c23379054.counterfilter)
end
-- 计数器过滤函数，仅对龙族怪兽进行计数。
function c23379054.counterfilter(c)
	return c:IsRace(RACE_DRAGON)
end
-- 效果发动条件：对方场上有怪兽存在，自己场上只有这张卡。
function c23379054.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上有怪兽存在。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己场上只有这张卡。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 效果费用：检查本回合是否已使用过此效果，若未使用则设置不能特殊召唤非龙族怪兽的效果。
function c23379054.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否已使用过此效果。
	if chk==0 then return Duel.GetCustomActivityCount(23379054,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个永续效果，使玩家不能特殊召唤非龙族怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c23379054.splimit)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止非龙族怪兽的特殊召唤。
function c23379054.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetRace()~=RACE_DRAGON
end
-- 过滤函数1：选择满足条件的墓地融合怪兽。
function c23379054.filter1(c,e,tp,lv,mc)
	return c:IsType(TYPE_FUSION) and c:IsAbleToRemove()
		-- 检查是否存在满足条件的同调怪兽。
		and Duel.IsExistingMatchingCard(c23379054.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+c:GetLevel(),mc)
end
-- 过滤函数2：选择满足条件的龙族同调怪兽。
function c23379054.filter2(c,e,tp,lv,mc)
	return c:IsLevel(lv) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
		-- 检查同调怪兽是否可以特殊召唤且场上是否有足够位置。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果目标选择函数：选择满足条件的墓地融合怪兽。
function c23379054.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23379054.filter1(chkc,e,tp,c:GetLevel(),c) end
	if chk==0 then return c:IsAbleToRemove()
		-- 检查是否存在满足条件的墓地融合怪兽。
		and Duel.IsExistingTarget(c23379054.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的墓地融合怪兽作为目标。
	local g=Duel.SelectTarget(tp,c23379054.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c:GetLevel(),c)
	g:AddCard(e:GetHandler())
	-- 设置操作信息：将要除外的卡数量设为2。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,tp,LOCATION_GRAVE)
	-- 设置操作信息：将要特殊召唤的卡数量设为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：执行效果的处理流程。
function c23379054.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local lv=c:GetLevel()+tc:GetLevel()
	local g=Group.FromCards(c,tc)
	-- 将目标卡和自身除外。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的龙族同调怪兽。
		local sg=Duel.SelectMatchingCard(tp,c23379054.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,nil)
		if sg:GetCount()>0 then
			-- 将选中的龙族同调怪兽特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
