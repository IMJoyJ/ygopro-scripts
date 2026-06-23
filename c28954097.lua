--ミラー ソードナイト
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡解放才能发动。把「镜剑骑士」以外的有「合成兽融合」的卡名记述的1只怪兽从卡组特殊召唤。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：自己场上有「有翼幻兽 奇美拉」存在，对方场上的怪兽把效果发动时，把场上·墓地的这张卡除外才能发动。那个效果无效。
local s,id,o=GetID()
-- 注册卡片的三个效果：②战斗不被破坏效果、①特殊召唤效果、③效果无效效果
function s.initial_effect(c)
	-- 记录该卡具有「合成兽融合」的卡名记述
	aux.AddCodeList(c,63136489)
	-- ②这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①自己·对方回合，把这张卡解放才能发动。把「镜剑骑士」以外的有「合成兽融合」的卡名记述的1只怪兽从卡组特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③自己场上有「有翼幻兽 奇美拉」存在，对方场上的怪兽把效果发动时，把场上·墓地的这张卡除外才能发动。那个效果无效
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"对方效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
	-- 将此卡从场上或墓地除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 判断战斗中的目标是否为自身或自身战斗对象
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- ①效果发动时，检查是否满足解放条件并执行解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以解放此卡并确保场上存在可用怪兽区
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 执行此卡的解放操作
	Duel.Release(c,REASON_COST)
end
-- 过滤函数，筛选满足条件的怪兽：具有「合成兽融合」记述、可特殊召唤、且不是镜剑骑士本身
function s.filter(c,e,tp)
	-- 筛选具有「合成兽融合」记述、可特殊召唤、且不是镜剑骑士本身的怪兽
	return aux.IsCodeListed(c,63136489) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- ①效果发动时，检查是否满足发动条件并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方提示发动了①效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果发动时，执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，检测场上是否存在「有翼幻兽 奇美拉」
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(4796100)
end
-- ③效果发动条件：对方怪兽发动效果时，己方场上有奇美拉且该效果可被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的发动玩家和位置信息
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	-- 判断连锁发动玩家为对方、位置在对方怪兽区、且该效果可被无效
	return tgp==1-tp and loc==LOCATION_MZONE and Duel.IsChainDisablable(ev)
		-- 判断己方场上有「有翼幻兽 奇美拉」
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ③效果发动时，设置操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示发动了③效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将使一个效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ③效果发动时，执行使效果无效的操作
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
