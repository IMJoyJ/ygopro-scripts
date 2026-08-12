--音響戦士ディージェス
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：1回合1次，自己主要阶段才能发动。选自己场上1只里侧守备表示的「音响战士」怪兽变成表侧守备表示。
-- ②：「音响战士」怪兽的效果发动的场合才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「音响战士 DJ调音台」以外的1只「音响战士」怪兽里侧守备表示特殊召唤。自己的场地区域有「音响放大器」存在的场合，可以作为代替从卡组把「音响战士 DJ调音台」以外的1只「音响战士」怪兽效果无效特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function c70204022.initial_effect(c)
	-- 记录卡片效果中记载了「音响放大器」的卡名。
	aux.AddCodeList(c,75304793)
	-- 注册灵摆怪兽的灵摆属性与灵摆召唤规则。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。选自己场上1只里侧守备表示的「音响战士」怪兽变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70204022,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c70204022.postg)
	e1:SetOperation(c70204022.posop)
	c:RegisterEffect(e1)
	-- ②：「音响战士」怪兽的效果发动的场合才能发动。灵摆区域的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70204022,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,70204022)
	e2:SetCondition(c70204022.pspcon)
	e2:SetTarget(c70204022.psptg)
	e2:SetOperation(c70204022.pspop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「音响战士 DJ调音台」以外的1只「音响战士」怪兽里侧守备表示特殊召唤。自己的场地区域有「音响放大器」存在的场合，可以作为代替从卡组把「音响战士 DJ调音台」以外的1只「音响战士」怪兽效果无效特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70204022,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,70204022+o)
	e3:SetTarget(c70204022.sptg)
	e3:SetOperation(c70204022.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤自己场上里侧守备表示且可以改变表示形式的「音响战士」怪兽。
function c70204022.posfilter(c)
	return c:IsSetCard(0x1066) and c:IsFacedown() and c:IsCanChangePosition()
end
-- 灵摆效果①的发动准备与效果处理（检查场上是否存在符合条件的怪兽并设置操作信息）。
function c70204022.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只里侧守备表示的「音响战士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c70204022.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置连锁处理信息，表示该效果包含改变表示形式的操作。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end
-- 灵摆效果①的实际效果处理（选择怪兽并将其变为表侧守备表示）。
function c70204022.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家选择1只符合条件的里侧守备表示「音响战士」怪兽。
	local tc=Duel.SelectMatchingCard(tp,c70204022.posfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 将选择的怪兽改变为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
-- 检查触发效果的卡是否是「音响战士」怪兽且发动的是怪兽效果。
function c70204022.pspcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1066)
end
-- 灵摆效果②的发动准备（检查怪兽区域空格及自身是否能特殊召唤）。
function c70204022.psptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息，表示该效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果②的实际效果处理（将自身特殊召唤）。
function c70204022.pspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将灵摆区域的这张卡以表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中除「音响战士 DJ调音台」以外、可以里侧守备表示特殊召唤的「音响战士」怪兽。
function c70204022.spfilter1(c,e,tp)
	return c:IsSetCard(0x1066) and not c:IsCode(70204022) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 过滤卡组中除「音响战士 DJ调音台」以外、可以特殊召唤的「音响战士」怪兽。
function c70204022.spfilter2(c,e,tp)
	return c:IsSetCard(0x1066) and not c:IsCode(70204022) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果①的发动准备（检查怪兽区域空格，并根据场上是否存在「音响放大器」来判断可特殊召唤的怪兽）。
function c70204022.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的场地区域是否存在「音响放大器」。
	local b=Duel.IsEnvironment(75304793,tp,LOCATION_FZONE)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在可以里侧守备表示特殊召唤的「音响战士」怪兽。
		and (Duel.IsExistingMatchingCard(c70204022.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 或者在「音响放大器」存在时，卡组中存在可以特殊召唤的「音响战士」怪兽。
			or b and Duel.IsExistingMatchingCard(c70204022.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)) end
	-- 设置连锁处理信息，表示该效果包含从卡组特殊召唤怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果①的实际效果处理（根据场地卡存在与否，选择里侧守备表示特殊召唤，或效果无效表侧表示特殊召唤）。
function c70204022.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场地区域是否存在「音响放大器」。
	local b=Duel.IsEnvironment(75304793,tp,LOCATION_FZONE)
	-- 如果存在「音响放大器」且卡组中存在可特殊召唤的「音响战士」怪兽。
	if b and Duel.IsExistingMatchingCard(c70204022.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 并且（卡组中没有可里侧守备表示特殊召唤的怪兽。
		and (not Duel.IsExistingMatchingCard(c70204022.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 或者玩家选择进行代替效果，即表侧表示特殊召唤）。
			or Duel.SelectYesNo(tp,aux.Stringid(70204022,3))) then  --"是否表侧表示特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只「音响战士」怪兽。
		local g=Duel.SelectMatchingCard(tp,c70204022.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 将该怪兽以表侧表示特殊召唤到场上（分解步骤）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 效果无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 完成特殊召唤的后续处理。
			Duel.SpecialSummonComplete()
		end
	else
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只用于里侧守备表示特殊召唤的「音响战士」怪兽。
		local g=Duel.SelectMatchingCard(tp,c70204022.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以里侧守备表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 让对方玩家确认里侧特殊召唤的怪兽。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
