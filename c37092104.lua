--アトランティスの怪腕
local s,id,o=GetID()
-- 初始化效果，注册三个效果：召唤成功时特殊召唤、特殊召唤成功时特殊召唤、连锁发动时无效效果
function s.initial_effect(c)
	-- 为卡片记录了38391684和22702055两张卡的编号
	aux.AddCodeList(c,38391684,22702055)
	-- 使该卡在怪兽区时可以变更为22702055的卡名
	aux.EnableChangeCode(c,22702055)
	-- 这张卡召唤成功的场合，以自己墓地1只「海王星的怪腕」为对象才能发动。特殊召唤那只怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 对方把效果发动时才能发动。使那个效果无效
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否可以特殊召唤的卡片，必须是38391684并且能特殊召唤到防守姿态
function s.spfilter(c,e,tp)
	-- 判断目标卡是否为38391684并且能特殊召唤到防守姿态
	return aux.IsCodeListed(c,38391684) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤效果的目标选择函数，检查是否有满足条件的墓地怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的墓地怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的操作函数，获取目标并进行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否与当前连锁相关且未受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽特殊召唤到场上防守姿态
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 无效效果发动的条件函数，检查是否满足发动条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件为：该卡未因战斗破坏、对方发动效果、发动的效果是怪兽类型、该连锁可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 过滤函数，用于判断是否可以作为代价送去墓地的卡，必须是22702055且正面表示
function s.cfilter(c)
	return c:IsCode(22702055) and c:IsAbleToGraveAsCost() and c:IsFaceup()
end
-- 无效效果发动的费用支付函数，检查是否有满足条件的卡并选择将其送去墓地
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡作为费用
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 调用bfgcost函数处理将自身除外作为费用
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择要送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 无效效果发动的目标设定函数，设置操作信息为使效果无效
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果发动的操作函数，使连锁的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使指定连锁的效果无效
	Duel.NegateEffect(ev)
end
