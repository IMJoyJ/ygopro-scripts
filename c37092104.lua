--アトランティスの怪腕
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以有「龙都 亚特兰蒂斯」的卡名记述的自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：这张卡只要在怪兽区域存在，卡名当作「海」使用。
-- ③：对方把怪兽的效果发动时，把场上·墓地的这张卡除外，把自己场上1张表侧表示的「海」送去墓地才能发动。那个发动的效果无效。
local s,id,o=GetID()
-- 初始化卡片效果：登记卡名记述列表，注册卡名变更效果，并注册①效果（召唤·特殊召唤时的墓地怪兽特殊召唤）和③效果（对方怪兽效果发动时的效果无效）
function s.initial_effect(c)
	-- 记录这张卡上记载着「龙都 亚特兰蒂斯」（38391684）和「海」（22702055）的卡名
	aux.AddCodeList(c,38391684,22702055)
	-- 注册②效果：这张卡在怪兽区域存在时卡名当作「海」（22702055）使用
	aux.EnableChangeCode(c,22702055)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合，以有「龙都 亚特兰蒂斯」的卡名记述的自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
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
	-- 这个卡名的③的效果1回合只能使用1次。③：对方把怪兽的效果发动时，把场上·墓地的这张卡除外，把自己场上1张表侧表示的「海」送去墓地才能发动。那个发动的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"效果无效"
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
-- 特殊召唤对象的过滤函数：判断卡的效果文本上是否记载着「龙都 亚特兰蒂斯」，且能否以守备表示特殊召唤
function s.spfilter(c,e,tp)
	-- 该卡的效果文本上记载着「龙都 亚特兰蒂斯」，并且能以守备表示特殊召唤的场合返回真
	return aux.IsCodeListed(c,38391684) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的对象选择函数：已在连锁中的卡需满足在自己墓地且符合过滤条件；发动检查时确认自己怪兽区域有空位且墓地存在可作为对象的卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己怪兽区域是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的、能成为效果对象的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将对对象的1张卡进行特殊召唤处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理：取得对象卡，若仍与连锁相关且不受王家长眠之谷影响，则将其守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第1个对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与当前连锁相关，并且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ③效果的发动条件：这张卡不是被战斗破坏的状态，对方把怪兽的效果发动，且该连锁可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡未处于被战斗破坏状态，且发动者是对方、发动的效果是怪兽效果、该连锁的效果可以被无效的场合返回真
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 代价用的过滤函数：卡名为「海」（22702055）、表侧表示、且能作为代价送去墓地的卡
function s.cfilter(c)
	return c:IsCode(22702055) and c:IsAbleToGraveAsCost() and c:IsFaceup()
end
-- ③效果的代价处理：发动检查时确认这张卡可以除外且自己场上存在满足条件的「海」；处理时把这张卡除外，并选择自己场上1张表侧表示的「海」送去墓地
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：这张卡能作为代价除外，并且自己场上存在满足条件的「海」
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 把这张卡从场上·墓地除外作为代价
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 提示玩家请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张表侧表示的「海」
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 把选择的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③效果的对象设定：无需发动检查（恒为真），设置操作信息为将该连锁的效果无效
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将连锁中的1个效果无效（效果无效分类）
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ③效果的处理：使对方发动的那个效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效
	Duel.NegateEffect(ev)
end
