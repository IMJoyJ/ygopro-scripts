--アトランティスの妖渦
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「亚特兰蒂斯的妖涡」外的1张有「龙都 亚特兰蒂斯」的卡名记述的卡从卡组送去墓地。
-- ②：这张卡只要在怪兽区域存在，卡名当作「海」使用。
-- ③：这张卡被送去墓地的场合，若自己场上有「海」存在则能发动。从手卡把1只水属性怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册卡名记述信息，注册卡名当作「海」使用的永续效果，并注册①召唤·特殊召唤时送墓效果和③送墓时特殊召唤效果两个诱发选发效果
function s.initial_effect(c)
	-- 在这张卡上记录其效果文本记述了「龙都 亚特兰蒂斯」（38391684）和「海」（22702055）的卡名
	aux.AddCodeList(c,38391684,22702055)
	-- 注册卡名变更效果，使这张卡在怪兽区域存在时卡名当作「海」使用（对应②效果）
	aux.EnableChangeCode(c,22702055)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。除「亚特兰蒂斯的妖涡」外的1张有「龙都 亚特兰蒂斯」的卡名记述的卡从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，若自己场上有「海」存在则能发动。从手卡把1只水属性怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义送墓对象的过滤函数，筛选可送去墓地的目标卡
function s.tgfilter(c)
	-- 条件是这张卡不是「亚特兰蒂斯的妖涡」自身、效果文本上记述了「龙都 亚特兰蒂斯」的卡名、且可以送去墓地
	return not c:IsCode(id) and aux.IsCodeListed(c,38391684) and c:IsAbleToGrave()
end
-- ①效果的目标函数：发动条件检测卡组中是否存在满足条件的卡，并设置送墓操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己卡组中是否存在至少1张满足过滤条件（记述「龙都 亚特兰蒂斯」卡名且非自身）的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣言将从卡组把1张卡送去墓地（不确定具体对象，targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数：提示玩家选择，从卡组选1张满足条件的卡并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要送去墓地的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果处理的原因把选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义特殊召唤对象的过滤函数，筛选手卡中可以特殊召唤的水属性怪兽
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义「海」的检测过滤函数：筛选场上表侧表示存在的「海」（22702055）
function s.cfilter(c)
	return c:IsCode(22702055) and c:IsFaceup()
end
-- ③效果的目标函数：发动条件检测怪兽区有空位、手卡有可特殊召唤的水属性怪兽、且自己场上有「海」存在，并设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己主要怪兽区域是否存在可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己手卡中是否存在至少1只可以特殊召唤的水属性怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检测自己场上是否存在表侧表示的「海」，或当前生效的场地卡为「海」（满足「自己场上有『海』存在」的条件）
		and (Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055,tp)) end
	-- 设置操作信息：宣言将从手卡把1只怪兽特殊召唤（不确定具体对象，targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果的处理函数：再次确认怪兽区有空位后，提示玩家从手卡选1只水属性怪兽并表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区域没有可用空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己手卡选择1只可以特殊召唤的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 把选中的水属性怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
