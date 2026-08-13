--アロマリリス－ローズマリー
-- 效果：
-- 植物族怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「芳香」卡加入手卡。
-- ②：自己基本分回复的场合才能发动（伤害步骤也能发动）。从手卡把最多3只「芳香」怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ③：把这张卡所连接区1只怪兽解放，以场上1张卡为对象才能发动。那张卡除外，自己回复1000基本分。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：先启用连接召唤限制并设定连接召唤条件（植物族怪兽2～3只），再依次注册①检索、②回复时特召、③解放除外并回复三个效果。
function c30989084.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡设定连接召唤手续：以2～3只植物族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,3)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「芳香」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己基本分回复的场合才能发动（伤害步骤也能发动）。从手卡把最多3只「芳香」怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RECOVER)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：把这张卡所连接区1只怪兽解放，以场上1张卡为对象才能发动。那张卡除外，自己回复1000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"卡片除外"
	e3:SetCategory(CATEGORY_RECOVER+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.rmcost)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数：判断卡片是否为「芳香」卡且能够加入手卡，作为①的检索对象条件。
function s.filter(c)
	return c:IsSetCard(0xc9) and c:IsAbleToHand()
end
-- 定义①的发动目标函数：在发动时检查卡组是否存在符合条件的「芳香」卡，若存在则向对方展示效果描述，并设置将卡组1张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：确认自己卡组存在至少1张满足条件的「芳香」卡（且能加入手卡），才能发动①。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示：本卡发动了①效果，并显示对应的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本连锁效果包含从卡组将1张卡加入手卡（CATEGORY_TOHAND），对象卡暂不确定，数量为1，来自自己的卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义①的效果处理函数：从卡组选择1张符合条件的「芳香」卡加入手卡，并让对方确认加入手卡的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示消息，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足s.filter且不受王家长眠之谷影响的「芳香」卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因送入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②的触发条件：只有自己回复基本分（ep==tp）时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 定义特召过滤函数：判断手卡中的怪兽是否为「芳香」卡，且能被当前效果特殊召唤到这张卡的连接区（表侧攻击表示）。
function s.spfilter(c,e,tp,zone)
	return c:IsSetCard(0xc9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 定义②的发动目标函数：获取这张卡的连接区可用主怪兽区，检查场上是否有空位且手卡有可特召的芳香怪兽，满足则设置特召操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 发动合法性检测：确认自己场上存在可用的主怪兽区空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认手卡中存在至少1只能够特殊召唤到这张卡连接区的「芳香」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	-- 设置操作信息：本连锁效果为特殊召唤（CATEGORY_SPECIAL_SUMMON），预计从手卡特殊召唤1只以上的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义②的效果处理函数：确认这张卡仍有效后，计算连接区可用空格，并考虑青眼精灵龙效果限制（最多1只），从手卡选择1至可特召数量的「芳香」怪兽特殊召唤到连接区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if zone==0 then return end
	-- 获取这张卡连接区中可用的主怪兽区空格数量，作为本次最多可特殊召唤的怪兽数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if ft<1 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出选择提示消息，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1～ft只满足条件且能特召到连接区的「芳香」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的连接区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 定义过滤函数：判断某只怪兽是否属于这张卡的连接区（用g包含判断），用于选取可解放的怪兽。
function s.cfilter(c,g)
	return g:IsContains(c)
end
-- 定义③的发动代价函数：从这张卡连接区的怪兽中选择1只解放作为发动的COST。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 代价合法性检测：确认这张卡的连接区存在至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,lg) end
	-- 选择这张卡连接区的1只怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,lg)
	-- 将选择的怪兽解放（REASON_COST），完成③发动所需的COST。
	Duel.Release(g,REASON_COST)
end
-- 定义过滤函数：判断卡片是否为植物族怪兽且可以以表侧守备表示被特殊召唤（该函数在本次脚本中未被实际使用）。
function s.rmfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义③的发动目标函数：选择场上1张可以除外的卡作为对象，并设置回复对象为自己、回复数值为1000，同时设置除外与回复的操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 弹出选择提示消息，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己或对方场上1张可以除外的卡作为本效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 将当前连锁的对象玩家设置为发动者自己，用于后续LP回复。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁对象参数为1000，作为要回复的基本分数值。
	Duel.SetTargetParam(1000)
	-- 设置操作信息：本连锁包含除外对象卡的效果（CATEGORY_REMOVE），对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：本连锁包含回复基本分的效果（CATEGORY_RECOVER），回复玩家为tp，回复数值为1000。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 定义③的效果处理函数：取回对象卡，若对象卡仍与效果相关则将其表侧表示除外，若除外成功则自己回复1000基本分。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与该效果相关，若相关则将其表侧表示除外；只有除外成功（返回值≠0）时才继续回复LP。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 以效果原因让自己回复1000基本分。
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end
