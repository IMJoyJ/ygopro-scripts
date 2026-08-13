--妖精霊クリボン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「古代妖精龙」或者兽族·植物族·天使族的光属性怪兽的其中任意种存在的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
-- ②：自己场上的其他的「古代妖精龙」或者有那个卡名记述的怪兽被效果破坏的场合，可以作为代替让场上的这张卡回到手卡。
local s,id,o=GetID()
-- 注册此卡的两个效果：①为手牌发动的起动效果，满足条件时特殊召唤自身并当作调整使用；②为场上的代替破坏效果，当其他符合条件的怪兽被效果破坏时可让自身回手代替破坏。同时登记此卡文本中记载的「古代妖精龙」。
function s.initial_effect(c)
	-- 将卡号25862681（古代妖精龙）登记为这张卡上记述的卡名，以便“有那个卡名记述的怪兽”的判断可识别。
	aux.AddCodeList(c,25862681)
	-- ①：自己场上有「古代妖精龙」或者兽族·植物族·天使族的光属性怪兽的其中任意种存在的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的其他的「古代妖精龙」或者有那个卡名记述的怪兽被效果破坏的场合，可以作为代替让场上的这张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
-- 定义①效果中“自己场上有「古代妖精龙」或者兽族·植物族·天使族的光属性怪兽”的判定条件：表侧表示且为「古代妖精龙」，或为光属性的兽族/植物族/天使族怪兽。
function s.cfilter(c)
	return c:IsFaceupEx() and (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST+RACE_FAIRY+RACE_PLANT) and c:IsType(TYPE_MONSTER)
		or c:IsCode(25862681))
end
-- ①效果的发动条件：自己场上有满足s.cfilter的「古代妖精龙」或兽·植物·天使族光属性怪兽存在（不包括这张卡自身）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索确认自己场上存在至少1张符合条件的卡（古代妖精龙或对应的光属性怪兽），且该卡不是效果持有者本身。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 设置①效果发动时的目标与合法条件：效果发动时（chk==0）检查能否空出怪兽区且此卡能否特殊召唤；效果处理时（chk==1）设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认自己主要怪兽区有可用区域，以保证这张卡能从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次效果将进行特殊召唤（对象为这张卡，数量为1），使其他卡能正确响应这个特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，则通过特殊召唤流程将其特殊召唤；特殊召唤成功后给它附加“当作调整使用”的效果，最后完成特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡与效果仍关联（未被无效或离场），并作为特殊召唤的一步将其以表侧表示特殊召唤到自己的主要怪兽区。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成整个特殊召唤流程，使SpecialSummonStep暂定的特殊召唤正式生效。
	Duel.SpecialSummonComplete()
end
-- 定义②效果中“被效果破坏的「古代妖精龙」或有其卡名记述的怪兽”的判定条件：被破坏的卡满足是「古代妖精龙」或记述该卡名的怪兽，且破坏原因含有效果并且不是代替破坏。
function s.repfilter(c)
	-- 判断被破坏的卡是「古代妖精龙」本身，或者是效果文本中记载着「古代妖精龙」卡名的怪兽卡。
	return (c:IsCode(25862681) or aux.IsCodeListed(c,25862681) and c:IsType(TYPE_MONSTER))
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②的发动检查与选择：确认此卡能回手、正被效果破坏的怪兽中存在满足repfilter的其他怪兽（不包括此卡自身），然后让玩家选择是否发动代替破坏效果。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and eg:IsExists(s.repfilter,1,nil,tp) and not eg:IsContains(c) end
	-- 弹出确认窗口，询问玩家是否用这张卡代替破坏（选择“是”则发动代替破坏效果）。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 作为代替破坏效果的判定值函数，对每个将要被破坏的怪兽用repfilter判定是否可用此卡代替破坏。
function s.repval(e,c)
	return s.repfilter(c)
end
-- ②效果处理：展示此卡并将此卡从场上返回手卡，以此代替原本要被效果破坏的怪兽的破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示此卡，提示正在处理它的代替破坏效果。
	Duel.Hint(HINT_CARD,0,id)
	-- 将此卡从场上返回持有者的手卡，完成代替破坏动作。
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
