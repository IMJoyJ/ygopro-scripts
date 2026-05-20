--PSYフレームギア・α
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：自己场上没有怪兽存在，对方把怪兽召唤·特殊召唤时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，从卡组把「PSY骨架装备·α」以外的1张「PSY骨架」卡加入手卡。这个效果特殊召唤的怪兽全部在结束阶段除外。
function c75425043.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c75425043.splimit)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在，对方把怪兽召唤·特殊召唤时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，从卡组把「PSY骨架装备·α」以外的1张「PSY骨架」卡加入手卡。这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75425043,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c75425043.condition)
	e2:SetTarget(c75425043.target)
	e2:SetOperation(c75425043.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤条件，此卡只能通过卡的效果特殊召唤。
function c75425043.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 过滤对方召唤或特殊召唤的怪兽。
function c75425043.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 检查发动条件：自己场上没有怪兽（或受「PSY骨架王·Λ」效果影响），且对方召唤或特殊召唤了怪兽。
function c75425043.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测「PSY骨架王·Λ」(8802510)的效果是否生效中。只要这张卡在怪兽区域存在，自己在自己场上有怪兽存在的场合也能把手卡的「PSY骨架装备」怪兽的效果发动。
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsPlayerAffectedByEffect(tp,8802510))
		and eg:IsExists(c75425043.cfilter,1,nil,1-tp)
end
-- 过滤手卡、卡组、墓地中可以特殊召唤的「PSY骨架驱动者」，且卡组中存在除自身以外可检索的「PSY骨架」卡。
function c75425043.spfilter1(c,e,tp)
	-- 检查卡片是否为「PSY骨架驱动者」，是否能特殊召唤，且卡组中是否存在除自身以外可检索的「PSY骨架」卡。
	return c:IsCode(49036338) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(c75425043.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- 过滤手卡、卡组、墓地中可以特殊召唤的「PSY骨架驱动者」，且卡组中存在除自身以外的「PSY骨架」卡。
function c75425043.spfilter2(c,e,tp)
	-- 检查卡片是否为「PSY骨架驱动者」，是否能特殊召唤，且卡组中是否存在除自身以外的「PSY骨架」卡。
	return c:IsCode(49036338) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(c75425043.thfilter0,tp,LOCATION_DECK,0,1,c)
end
-- 过滤卡组中除「PSY骨架装备·α」以外的「PSY骨架」卡。
function c75425043.thfilter0(c)
	return c:IsSetCard(0xc1) and not c:IsCode(75425043)
end
-- 过滤卡组中除「PSY骨架装备·α」以外且能加入手卡的「PSY骨架」卡。
function c75425043.thfilter(c)
	return c:IsSetCard(0xc1) and not c:IsCode(75425043) and c:IsAbleToHand()
end
-- 检查效果发动的可行性：不受「青眼精灵龙」限制、满足场上怪兽数量或「PSY骨架王·Λ」条件、有2个以上怪兽区域空位、自身可特殊召唤，且存在可特召的「PSY骨架驱动者」和可检索的卡。
function c75425043.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测「PSY骨架王·Λ」(8802510)的效果是否生效中。只要这张卡在怪兽区域存在，自己在自己场上有怪兽存在的场合也能把手卡的「PSY骨架装备」怪兽的效果发动。
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsPlayerAffectedByEffect(tp,8802510))
		-- 检查自己场上的怪兽区域空位是否在2个以上。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡、卡组、墓地是否存在满足特殊召唤条件的「PSY骨架驱动者」（且卡组有可检索卡）。
		and Duel.IsExistingMatchingCard(c75425043.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡、卡组、墓地特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 设置加入手卡的操作信息，表示将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑：特殊召唤自身与「PSY骨架驱动者」，注册结束阶段除外的延迟效果，并从卡组检索1张「PSY骨架」卡。
function c75425043.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地选择1只满足条件的「PSY骨架驱动者」（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c75425043.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	-- 准备以表侧表示特殊召唤选中的「PSY骨架驱动者」。
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 准备以表侧表示特殊召唤这张卡（PSY骨架装备·α）。
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(75425043,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	c:RegisterFlagEffect(75425043,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 完成上述怪兽的特殊召唤。
	Duel.SpecialSummonComplete()
	g:AddCard(c)
	g:KeepAlive()
	-- 从卡组把「PSY骨架装备·α」以外的1张「PSY骨架」卡加入手卡。这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c75425043.rmcon)
	e1:SetOperation(c75425043.rmop)
	-- 注册在结束阶段将特殊召唤的怪兽除外的全局效果。
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「PSY骨架装备·α」以外的「PSY骨架」卡。
	local g2=Duel.SelectMatchingCard(tp,c75425043.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g2:GetCount()>0 then
		-- 将选中的卡加入玩家手卡。
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g2)
	end
end
-- 过滤带有特定标记（fid）的卡片，用于结束阶段除外。
function c75425043.rmfilter(c,fid)
	return c:GetFlagEffectLabel(75425043)==fid
end
-- 检查是否存在带有特定标记的卡片，若不存在则清理卡片组并重置除外效果。
function c75425043.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c75425043.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的执行操作，过滤出带有特定标记的怪兽并将其除外。
function c75425043.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c75425043.rmfilter,nil,e:GetLabel())
	-- 将这些怪兽以表侧表示除外。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
