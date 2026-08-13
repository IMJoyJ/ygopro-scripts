--ロイヤル・ストレート・スラッシャー
-- 效果：
-- 这张卡不能通常召唤，用「同花大顺」的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地有「王后骑士」「卫兵骑士」「国王骑士」全部存在的场合才能发动。1～5星的怪兽各1只从手卡·卡组送去墓地，对方场上的卡全部破坏。
-- ②：这张卡被战斗破坏时，以自己墓地最多3只战士族·光属性怪兽为对象才能发动。那些怪兽特殊召唤。
local s,id,o=GetID()
-- 定义并注册本卡的效果：设置特殊召唤限制（只能由「同花大顺」特殊召唤），注册①效果（送墓5张等级各异1~5星怪兽并破坏对方全场）和②效果（被战破时特召墓地战士族·光属性怪兽），两种效果各自1回合1次。
function s.initial_effect(c)
	-- 将「王后骑士」「卫兵骑士」「国王骑士」的卡号登记到本卡，使本卡视为记载着这些卡名。
	aux.AddCodeList(c,25652259,64788463,90876561)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「同花大顺」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置EFFECT_SPSUMMON_CONDITION的值为恒假，即这张卡不能用其他效果特殊召唤，只能通过「同花大顺」的效果（无视召唤条件）特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：自己墓地有「王后骑士」「卫兵骑士」「国王骑士」全部存在的场合才能发动。1～5星的怪兽各1只从手卡·卡组送去墓地，对方场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗破坏时，以自己墓地最多3只战士族·光属性怪兽为对象才能发动。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：自己墓地同时存在「王后骑士」「卫兵骑士」「国王骑士」三张卡时才可发动。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在「王后骑士」（卡号25652259）。
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,25652259)
		-- 检查自己墓地是否存在「卫兵骑士」（卡号64788463）。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,64788463)
		-- 检查自己墓地是否存在「国王骑士」（卡号90876561）。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,90876561)
end
-- 筛选可用于①效果送去墓地的卡：必须是等级5以下的怪兽，且能够送去墓地。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(5) and c:IsAbleToGrave()
end
-- ①效果的目标阶段：确认能否发动（对方场上有卡且手卡·卡组能选出5只等级各异的1~5星怪兽），并设置发动后需要的操作信息（送墓5张、破坏对方全场）。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若对方场上没有卡，则无法满足“对方场上的卡全部破坏”的前提，发动不合法，返回false。
		if not Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) then return false end
		-- 获取自己手卡·卡组中所有符合条件的1~5星怪兽（s.tgfilter），作为送墓候选集合。
		local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		-- 检查候选集合中是否能选出5只等级互不相同的怪兽（即1～5星各1只），能则发动条件成立。
		return tg:CheckSubGroup(aux.dlvcheck,5,5)
	end
	-- 获取对方场上的所有卡，作为后续要被破坏的卡集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次效果将把5张卡从手卡·卡组送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,5,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置操作信息：本次效果将破坏对方场上全部卡（CATEGORY_DESTROY），破坏数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的实际处理：让玩家从手卡·卡组选择5只等级各异的1~5星怪兽送去墓地，然后将对方场上的卡全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段重新获取手卡·卡组中符合条件的1~5星怪兽，用于选择送墓对象。
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 向玩家显示“请选择要送去墓地的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从候选中选出5只且等级互不相同的怪兽（1~5星各1只）；若无法选出，sg为nil。
	local sg=tg:SelectSubGroup(tp,aux.dlvcheck,false,5,5)
	if sg then
		-- 将选出的5只怪兽从手卡·卡组送去墓地，送墓原因记为效果。
		Duel.SendtoGrave(sg,REASON_EFFECT)
		-- 送墓后，获取对方场上的全部卡，作为此次破坏的对象。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			-- 将对方场上的全部卡破坏，破坏原因为效果。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- ②效果的特殊召唤筛选：对象必须是战士族·光属性怪兽，并且满足特殊召唤的苏生限制。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择与发动检查：需要自己主要怪兽区有空位，且墓地存在至少1只符合条件的战士族·光属性怪兽；选择对象数量上限为可用区域数（最多3只，若青眼精灵龙效果生效则最多1只），并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 计算己方主要怪兽区当前可用的空格数，作为可特殊召唤数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动合法性检查时，必须满足有可用怪兽区域且墓地存在至少1只符合条件的对象怪兽。
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>3 then ft=3 end
	-- 显示“请选择要特殊召唤的卡”的提示信息，用于选择墓地对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1～ft只符合条件的怪兽作为对象，并登记为这张卡的效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置操作信息：本次效果将特殊召唤所选择的这些对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
-- ②效果的实际处理：获取连锁对象中仍与效果相关的墓地怪兽；若青眼精灵龙效果生效且对象超过1只则不处理；若对象数量超过可用区域，则从中选择可特召的数量；最后特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段重新计算可用怪兽区数量，用于判断能特殊召唤几只。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取该连锁记录的目标卡组（即发动时选择的墓地怪兽对象）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 当可用区域不足以特殊召唤全部对象时，提示玩家选择其中要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将最终确定的对象怪兽以表侧表示特殊召唤到己方场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
