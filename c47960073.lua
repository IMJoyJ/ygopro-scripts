--K9－04号 咒
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤的场合才能发动。从卡组把1只机械族以外的「K9」怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「K9」怪兽不能从额外卡组特殊召唤。
-- ③：把自己场上1张表侧表示的「K9」卡送去墓地才能发动。把对方手卡全部确认。
local s,id,o=GetID()
-- 创建并注册三个效果：e1为①的不用解放作召唤的规则效果；e2为②的召唤成功时从卡组特召机械族以外「K9」怪兽的选发诱发效果，并用id设置1回合1次；e3为③的把自己场上表侧「K9」卡送墓、确认对方手牌的起动效果，用id+o设置1回合1次。
function s.initial_effect(c)
	-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放召唤(K9-04号 咒)"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤的场合才能发动。从卡组把1只机械族以外的「K9」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：把自己场上1张表侧表示的「K9」卡送去墓地才能发动。把对方手卡全部确认。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"确认手卡"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.cfcost)
	e3:SetTarget(s.cftg)
	e3:SetOperation(s.cfop)
	c:RegisterEffect(e3)
end
-- 无解放召唤规则效果的条件：c为nil时供系统判定该召唤方式可用；实际进行召唤时，须满足本次召唤无需解放（minc==0）、这张卡等级不低于5、自己主要怪兽区有空位，且对方手牌有2张以上。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定无解放召唤的前提：本次召唤解放数为0（minc==0）、这张卡为等级5以上的怪兽，且自己主要怪兽区域有空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 同时需要对方手牌存在至少2张卡，满足①的“对方手卡是2张以上”条件。
		and Duel.IsExistingMatchingCard(aux.TRUE,c:GetControler(),0,LOCATION_HAND,2,nil)
end
-- 检索/选择的怪兽筛选：必须是「K9」字段怪兽、不是机械族，并且能被当前效果特殊召唤（符合苏生限制与召唤条件）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cb) and not c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动检查：只能在主怪兽区有空格且卡组中存在符合条件的「K9」怪兽时才能发动；该效果不取对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己的主要怪兽区有可用空格，保证特召位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中存在至少1只满足s.spfilter（机械族以外的「K9」怪兽）可以被特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向连锁登记本次操作将进行从卡组特殊召唤1只怪兽，用于其他卡对发动/效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若主怪兽区仍有空位，则让玩家从卡组选1只符合条件的「K9」怪兽表侧表示特殊召唤；特殊召唤成功后，给那只怪兽附加自肃效果：只要它表侧表示在自己场上存在，自己不能从额外卡组特殊召唤非「K9」怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主怪兽区仍有可用空格，若没有则结束处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1张满足s.spfilter的机械族以外的「K9」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上；若特殊召唤成功（返回值不为0），继续处理后续自肃效果。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「K9」怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「K9-04号 咒」的效果特殊召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CONTROL)
		tc:RegisterEffect(e1,true)
	end
end
-- ③的代价筛选：自己场上表侧表示、属于「K9」字段且可以作为cost送去墓地的卡。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1cb) and c:IsAbleToGraveAsCost()
end
-- ③的代价处理：从自己场上选择1张表侧表示的「K9」卡送去墓地作为发动代价；先检查是否存在合法代价，再选择并送墓。
function s.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价的合法性检查：自己场上存在至少1张表侧表示且能作为cost送去墓地的「K9」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己场上选择1张满足s.cfilter的「K9」卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选择的卡以cost原因送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 自肃效果的限制对象：不是「K9」字段且位于额外卡组的怪兽不能被特殊召唤，即禁止从额外卡组特殊召唤非「K9」怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0x1cb) and c:IsLocation(LOCATION_EXTRA)
end
-- ③的发动条件检查：对方手牌存在至少1张非公开状态的卡（即还未被双方确认的卡），才能发动确认效果。
function s.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若对方手牌中存在至少1张未公开的卡，则效果可以发动；这里不取对象。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) end
end
-- ③效果处理：取得对方全部手牌，若非空则展示给发动玩家，然后洗切对方手牌。
function s.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌的所有卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 将对方全部手牌展示给发动玩家确认。
		Duel.ConfirmCards(tp,g)
		-- 洗切对方手牌，作为确认手牌后的收尾处理（避免通过手牌顺序获得额外信息）。
		Duel.ShuffleHand(1-tp)
	end
end
