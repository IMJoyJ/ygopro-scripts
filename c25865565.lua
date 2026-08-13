--水晶機巧－サルファドール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上1张「水晶机巧」卡为对象才能发动。那张卡破坏，这张卡特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「水晶机巧-柠晶救龙」以外的最多2张「水晶机巧」卡送去墓地（同名卡最多1张）。
local s,id,o=GetID()
-- 为这张卡注册两个效果：①是手卡·墓地的起动效果，取对象破坏自己场上的「水晶机巧」卡后特殊召唤自身，并附加机械族自肃；②是召唤·特殊召唤成功时触发的送墓效果，分别注册召唤成功和特殊召唤成功两个触发事件，且①②各1回合1次。
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以自己场上1张「水晶机巧」卡为对象才能发动。那张卡破坏，这张卡特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.spdtg)
	e1:SetOperation(s.spdop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「水晶机巧-柠晶救龙」以外的最多2张「水晶机巧」卡送去墓地（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义①取对象时的对象筛选条件：必须是表侧表示的「水晶机巧」卡，且将其破坏后自己场上仍有可用的怪兽区。
function s.desfilter(c,tp)
	-- 对象必须表侧表示且属于「水晶机巧」（0xea），并且破坏该卡后自己场上有可用的怪兽区（用于特殊召唤自身）。
	return c:IsFaceup() and c:IsSetCard(0xea) and Duel.GetMZoneCount(tp,c)>0
end
-- ①的效果发动前检查：自身可以从手卡·墓地特殊召唤，且自己场上存在1张以上满足条件的「水晶机巧」卡可作为对象；若指定了对象，还须满足对象条件。
function s.spdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在至少1张可作为对象的「水晶机巧」卡，以满足发动条件。
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 向玩家显示选择提示，要求选择1张要破坏的「水晶机巧」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1张满足条件的「水晶机巧」卡作为效果对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息：本连锁将破坏对象g，数量为1，用于星尘龙等卡的对应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本连锁将特殊召唤这张卡自身（c），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理①：若选择的对象仍与效果关联且被效果破坏，且自身仍与效果关联并满足墓地特召条件，则将自身特殊召唤。
function s.spdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①发动时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍然与效果关联，并且能够被效果破坏（破坏处理成功）。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 确认这张卡（效果发动者）仍然与效果关联，且不在王家长眠之谷影响下（即墓地效果可用）。
		and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「水晶机巧-柠晶救龙」以外的最多2张「水晶机巧」卡送去墓地（同名卡最多1张）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤机械族以外怪兽的自肃效果注册到当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃限制：从额外卡组特殊召唤的怪兽必须是机械族；若怪兽不是机械族且位于额外卡组，则禁止特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义②送墓对象的过滤条件：卡组中的「水晶机巧」卡，可以送去墓地，且卡名不能是「水晶机巧-柠晶救龙」自身。
function s.tgfilter(c)
	return c:IsSetCard(0xea) and c:IsAbleToGrave() and not c:IsCode(id)
end
-- ②的发动条件和操作信息设置：发动时检查卡组是否有符合条件的「水晶机巧」卡，并设置送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中存在至少1张满足送墓条件的「水晶机巧」卡时，②才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本连锁会把最多（此处记1）张卡从卡组送去墓地，位置为卡组，玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理②：从卡组选出1～2张卡名互不相同的「水晶机巧」卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得卡组中所有满足送墓条件的「水晶机巧」卡，作为可选集合。
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #tg>0 then
		-- 显示选择提示，要求玩家选择要送去墓地的「水晶机巧」卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从可选集合中选择1～2张，且选中的卡卡名互不相同（同名卡最多1张）。
		local sg=tg:SelectSubGroup(tp,aux.dncheck,false,1,2)
		-- 若成功选择了卡，则将它们从卡组送去墓地。
		if sg then Duel.SendtoGrave(sg,REASON_EFFECT) end
	end
end
