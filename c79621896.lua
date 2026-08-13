--デーモンの根源
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，把这张卡以外的自己的手卡·场上1只「恶魔」怪兽解放才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的手卡·卡组·墓地把1只攻击力2500的恶魔族·6星怪兽特殊召唤。
-- ③：自己场上有「恶魔召唤」存在，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 定义「恶魔根源」的效果初始化函数：调用aux.AddCodeList登记「恶魔召唤」卡号；注册①效果（手牌中解放1只「恶魔」怪兽来特殊召唤自身，1回合1次）、②效果（召唤·特殊召唤时从手牌·卡组·墓地特殊召唤1只攻击力2500的恶魔族6星怪兽，召唤与特殊召唤分别由e2/e3触发）和③效果（自己场上有「恶魔召唤」且对方发动怪兽效果时，无效并破坏，1回合1次）。
function s.initial_effect(c)
	-- 将卡号70781052（即「恶魔召唤」）登记到卡片的关联卡名列表中，用于脚本内判断“自己场上有「恶魔召唤」”等情形。
	aux.AddCodeList(c,70781052)
	-- ①：这张卡在手卡存在的场合，把这张卡以外的自己的手卡·场上1只「恶魔」怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的手卡·卡组·墓地把1只攻击力2500的恶魔族·6星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：自己场上有「恶魔召唤」存在，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"无效并破坏"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 定义①效果解放素材的过滤条件：候选卡必须是怪兽且属于「恶魔」卡名系列（SetCard 0x45），并且解放该卡后自己场上仍有可用的怪兽区空格，以免无法特殊召唤自身。
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x45)
		-- 并且检查解放这张候选怪兽后，自己怪兽区仍有空格，确保后续可以把「恶魔根源」特殊召唤到场上。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 定义①效果发动代价的支付：从自己的手卡·场上选择1只除自身以外的「恶魔」怪兽解放。先检查满足条件的卡是否存在，再选择并实际解放（解放原因为COST，不能被无效）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动条件检查阶段，确认自己手卡·场上存在1只满足cfilter（「恶魔」怪兽）且不是本卡自身的可解放怪兽，作为能否发动①的判定。
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,c,tp) end
	-- 向玩家显示“请选择要解放的卡”的提示，让玩家选择解放素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己的手卡·场上选择1只满足cfilter条件的「恶魔」怪兽作为解放素材，排除本卡自身（通过ex参数排除）。
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,c,tp)
	-- 将选中的1只「恶魔」怪兽解放，作为发动①效果的代价（COST）。
	Duel.Release(g,REASON_COST)
end
-- 定义①效果发动时的目标设定：检查「恶魔根源」自身确实可以特殊召唤，并登记“特殊召唤自身”的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将该连锁的处理信息登记为特殊召唤本卡，特殊召唤对象为「恶魔根源」自身，数量为1，为效果处理时和其他卡片响应做准备。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义①效果处理：若「恶魔根源」仍与当前连锁相关（未被除外等），则将其特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将「恶魔根源」以表侧表示特殊召唤到自己场上（位置由系统自动选择空格）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果可特殊召唤怪兽的过滤条件：攻击力为2500、种族为恶魔族、等级为6星，并且可以被特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsAttack(2500) and c:IsRace(RACE_FIEND) and c:IsLevel(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义②效果的发动条件：检查自己怪兽区有空位，且手牌·卡组·墓地中存在至少1只满足spfilter2的怪兽；将特殊召唤操作信息写入连锁。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查时，先确认自己的主要怪兽区拥有可用空格，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己的手牌·卡组·墓地中有至少1只满足spfilter2条件的怪兽（攻击力2500的恶魔族·6星）可以作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本次效果将进行特殊召唤，预计数量为1，待选范围为手牌·卡组·墓地（因不取对象，targets为nil，但标明来源位置）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义②效果处理：先再次确认怪兽区有空格，然后让玩家从手牌·卡组·墓地选择1只符合条件的怪兽，并特殊召唤。选择时使用aux.NecroValleyFilter过滤，避免「王家长眠之谷」对墓地的影响。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上已没有可用的怪兽区，则不能进行特殊召唤，直接终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，用于选择特殊召唤的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手牌·卡组·墓地选择1只满足spfilter2条件的怪兽（经NecroValleyFilter处理，受「王家长眠之谷」影响的墓地卡不可选）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的那只怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义用于检查场上是否存在「恶魔召唤」的过滤条件：卡片正面表示且卡号为70781052（即「恶魔召唤」）。
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(70781052)
end
-- 定义③效果的发动条件：对方发动怪兽效果，且该发动可被无效，并且自己场上有表侧表示的「恶魔召唤」存在。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件是：效果发动者是对方（rp≠tp）、该效果是怪兽效果、且当前连锁的发动能够被无效。
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 并且自己场上存在至少1张表侧表示的「恶魔召唤」（卡号70781052）。
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义③效果的发动目标：该效果必定能发动，登记“无效”操作信息；同时若对方发动效果的卡可以被破坏且仍与该效果相关，则追加登记“破坏”操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的“无效发动”操作信息登记，目标为eg（对方发动的那个对象），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 将“破坏”操作信息登记，目标同样为eg（对方发动的那张卡），数量为1，用于效果处理时破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义③效果处理：尝试无效对方那个怪兽效果的发动；如果成功且对应卡片仍在连锁中，则将那张卡破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果对方怪兽效果的发动被无效成功，并且被无效的那张卡仍然与该连锁相关（未被除外等），则继续执行破坏；否则不破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 以“效果破坏”的方式，将对方被无效的那个怪兽卡破坏并送入墓地。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
