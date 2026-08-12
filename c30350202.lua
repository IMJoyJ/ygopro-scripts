--凶征竜－エクレプシス
-- 效果：
-- 龙族7星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合，以自己的墓地·除外状态的1只4星以下的「征龙」怪兽为对象才能发动。把1只在那只怪兽有卡名记述的7星或7阶的「征龙」怪兽从自己的卡组·除外状态特殊召唤。那之后，作为对象的怪兽回到卡组。
-- ②：对方把魔法·陷阱卡的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效并除外。
local s,id,o=GetID()
-- 初始化效果，设置XYZ召唤程序并注册两个效果
function s.initial_effect(c)
	-- 设置XYZ召唤条件为龙族7星怪兽叠放2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),7,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合，以自己的墓地·除外状态的1只4星以下的「征龙」怪兽为对象才能发动。把1只在那只怪兽有卡名记述的7星或7阶的「征龙」怪兽从自己的卡组·除外状态特殊召唤。那之后，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱卡的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效并除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	-- 设置效果目标处理函数为辅助函数nbtg
	e2:SetTarget(aux.nbtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：此卡为XYZ召唤成功时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 选择目标过滤器：对象为己方墓地或除外状态的4星以下的「征龙」怪兽
function s.tfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1c4) and c:IsLevelBelow(4) and c:IsAbleToDeck()
		-- 检查是否存在满足条件的特殊召唤怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp,c)
end
-- 特殊召唤怪兽过滤器：对象为己方卡组或除外状态的「征龙」怪兽，且其卡名记载于目标怪兽上，且等级或阶数为7
function s.spfilter(c,e,tp,ec)
	return c:IsFaceupEx() and c:IsSetCard(0x1c4)
		-- 检查目标怪兽是否记载了该怪兽的卡号
		and aux.IsCodeListed(ec,c:GetCode()) and (c:IsLevel(7) or c:IsRank(7))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 设置效果目标选择函数，检查是否有满足条件的目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tfilter(chkc,e,tp) end
	-- 检查是否有足够的场上空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- 效果处理函数：选择目标怪兽并特殊召唤符合条件的怪兽，然后将目标怪兽送回卡组
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 检查是否有足够的场上空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp,tc)
	-- 执行特殊召唤操作
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理流程
		Duel.BreakEffect()
		-- 判断目标怪兽是否受王家长眠之谷影响
		if aux.NecroValleyFilter()(tc) then
			-- 将目标怪兽送回卡组
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 无效效果发动条件：对方发动魔法或陷阱卡且未被战斗破坏
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否可以无效连锁发动
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		and ep==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 无效效果发动成本：移除2个超量素材
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 无效效果处理函数：使发动无效并除外
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使发动无效且目标卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将目标卡除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
