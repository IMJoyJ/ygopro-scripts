--再世記
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组选1只「再世」怪兽加入手卡或送去墓地。自己场上有「再世」怪兽存在的场合，也能作为代替把1只攻击力和守备力是2500的怪兽从卡组加入手卡。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只「再世」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 为「再世记」注册①和②两个效果：①为魔法卡发动效果，从卡组选「再世」怪兽加入手卡或送去墓地；②为墓地起动效果，把这张卡除外，从自己墓地特殊召唤1只「再世」怪兽。
function s.initial_effect(c)
	-- ①：从卡组选1只「再世」怪兽加入手卡或送去墓地。自己场上有「再世」怪兽存在的场合，也能作为代替把1只攻击力和守备力是2500的怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组操作"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只「再世」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的条件：这张卡不是这个回合被送去墓地的（送去墓地的回合不能发动）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义检索/送墓候选卡的条件：候选卡可以是「再世」怪兽且能被加入手卡或送去墓地；若自己场上有表侧表示「再世」怪兽，则也可以是攻击力和守备力均为2500的怪兽且能被加入手卡。
function s.thfilter(c,tp)
	return c:IsSetCard(0x1c5) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
		-- 检查自己场上是否存在表侧表示的「再世」怪兽，作为允许选择2500攻守怪兽的追加条件。
		or Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x1c5)
		and c:IsAttack(2500) and c:IsDefense(2500) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义①效果的发动目标判定函数，用于检查发动时是否存在可检索/送墓的候选卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认卡组中是否存在至少1张满足s.thfilter条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- ①效果处理：从卡组选择符合条件的1张卡，根据情况将其加入手卡或送去墓地；若选中的是「再世」怪兽，则让玩家选择加入手卡还是送去墓地。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要操作的卡”的提示信息，用于检索卡组卡片的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1张满足s.thfilter条件的卡，作为本次效果处理的对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断选中的卡是否应加入手卡：若它不是「再世」怪兽，或不能送去墓地，或玩家在“加入手卡/送去墓地”选项中选择了加入手卡，则执行加入手卡。
	if tc:IsAbleToHand() and (not tc:IsSetCard(0x1c5) or not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 以效果原因将选中的卡片加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张加入手卡的卡，确认检索到的卡片内容。
		Duel.ConfirmCards(1-tp,tc)
	elseif tc:IsAbleToGrave() then
		-- 以效果原因将选中的卡片送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 定义②效果特殊召唤的过滤条件：对象必须是「再世」怪兽，且能被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义②效果的发动条件与取对象处理：确认自己场上有空位、墓地有符合条件的「再世」怪兽，并选择1只作为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 在发动合法性检查时，确认自己场上有空余的主要怪兽区域，供特殊召唤使用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查墓地是否存在至少1只可作为特殊召唤对象的「再世」怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只符合条件的「再世」怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次效果处理将进行特殊召唤的操作信息，供连锁判定和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：确认对象仍可特殊召唤后，将其从墓地特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否仍与效果相关（未离场或解除联系），且不受“王家长眠之谷”等从墓地特殊召唤的限制。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
