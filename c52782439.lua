--特別ダイヤ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1张「临时行车时间表」或「紧急行车时间表」加入手卡。那之后，可以在对方场上把1只「行车时间表衍生物」（机械族·地·10星·攻/守3000）特殊召唤。
-- ②：把墓地的这张卡除外，以自己的墓地·除外状态的1只机械族·10星怪兽为对象才能发动。自己场上1张卡送去墓地，作为对象的怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为「特别行车时间表」注册两个效果：①的检索/衍生物特殊召唤效果（e1，魔法卡发动）和②的墓地除外自身起动效果（e2）。
function s.initial_effect(c)
	-- 登记卡名关联：将「紧急行车时间表」(25274141)和「临时行车时间表」(97520701)的卡号加入本卡记载的卡名列表，用于相关检索/联动判定。
	aux.AddCodeList(c,25274141,97520701)
	-- ①：从卡组把1张「临时行车时间表」或「紧急行车时间表」加入手卡。那之后，可以在对方场上把1只「行车时间表衍生物」（机械族·地·10星·攻/守3000）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己的墓地·除外状态的1只机械族·10星怪兽为对象才能发动。自己场上1张卡送去墓地，作为对象的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置e2的发动代价：把墓地的这张卡除外（aux.bfgcost为除外自身作为代价的通用函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义检索过滤条件：只选择卡号为25274141（紧急行车时间表）或97520701（临时行车时间表）且能够加入手卡的卡。
function s.thfilter(c)
	return c:IsCode(25274141,97520701) and c:IsAbleToHand()
end
-- 定义①的发动条件：卡组存在至少1张满足检索条件的卡；并设置操作信息为从卡组将1张卡加入手卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：卡组中是否存在至少1张满足s.thfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时将执行“从卡组把1张卡加入手卡”的操作信息（供连锁/判定使用）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义①的效果处理：检索并加入手卡，向对方确认；随后根据玩家选择及场地情况，可在对方场上特殊召唤1只“行车时间表衍生物”。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足s.thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 检查对方场上是否有空余的怪兽区可用。
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 检查当前玩家是否可以在对方场上以表侧表示特殊召唤1只“行车时间表衍生物”（机械族·地·10星·攻/守3000的衍生物）。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,3000,3000,10,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
			-- 弹出是否特殊召唤衍生物的确认询问。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤衍生物？"
			-- 中断当前效果链，使后续的衍生物特殊召唤作为独立效果处理，避免时点被占用。
			Duel.BreakEffect()
			-- 创建“行车时间表衍生物”的衍生物卡片，卡号为id+o。
			local token=Duel.CreateToken(tp,id+o)
			-- 将衍生物特殊召唤到对方场上（1-tp），表侧表示，不检查召唤条件。
			Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义②的特殊召唤对象过滤函数：对象必须是表侧表示、机械族、10星且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_MACHINE) and c:IsLevel(10)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义用于选择“送去墓地的自己场上卡片”的过滤函数：卡可以送去墓地，且（chk为真时）送墓后自己场上仍有空余怪兽区。
function s.cfilter(c,tp,chk)
	-- 判断该卡能否送去墓地，并在需要时确保送墓后有空余怪兽区。
	return c:IsAbleToGrave() and (not chk or Duel.GetMZoneCount(tp,c)>0)
end
-- 定义②的发动条件与取对象：选择自己墓地或除外状态的1只机械族·10星怪兽作为对象；同时场上需要有1张可以送去墓地且不会导致无法特殊召唤的卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	-- 检查自己墓地·除外状态是否存在满足条件的机械族·10星怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 同时检查场上是否存在1张满足s.cfilter（可送墓并空出格子）的卡。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true) end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1张墓地/除外的机械族·10星怪兽作为效果对象，并建立与当前连锁的关联。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理时“把自己场上1张卡送去墓地”的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	-- 设置效果处理时“特殊召唤对象怪兽”的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义②的效果处理：选择自己场上1张卡送去墓地；若送墓成功且对象仍与效果关联，则将对象特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local g=Group.CreateGroup()
	-- 显示选择提示，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 检查场上是否存在满足“送墓后可空出怪兽区”条件的卡（chk=true）。
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true) then
		-- 选择1张送墓后能空出怪兽区的自己场上卡送去墓地。
		g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,true)
	else
		-- 选择1张仅满足“可送去墓地”的自己场上卡送去墓地。
		g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,false)
	end
	-- 确认已选择并成功送去墓地至少1张卡，且那张卡确实在墓地。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 确认对象怪兽仍与本次效果关联，且不受“王家长眠之谷”等效果限制。
		and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 更新场地信息，确保后续特殊召唤前的状态正确。
		Duel.AdjustAll()
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
