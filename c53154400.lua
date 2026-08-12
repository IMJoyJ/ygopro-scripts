--サイコ・ローヴァー
-- 效果：
-- ①：这张卡特殊召唤成功的场合才能发动。掷1次骰子。1·6出现的场合，选场上最多2张卡破坏。
-- ②：这张卡被送去墓地的场合才能发动。掷1次骰子。2～5出现的场合，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 创建两个诱发效果，分别对应特殊召唤成功和送去墓地时的处理
function s.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。掷1次骰子。1·6出现的场合，选场上最多2张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.dictg)
	e1:SetOperation(s.dicop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。掷1次骰子。2～5出现的场合，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果处理前检查场上是否存在满足条件的卡
function s.dictg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置操作信息为投掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 执行骰子效果处理，若骰子结果为1或6则破坏场上卡
function s.dicop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家投掷1次骰子
	local d=Duel.TossDice(tp,1)
	if d==1 or d==6 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上最多2张卡作为破坏目标
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
		if g:GetCount()>0 then
			-- 显示选中卡的动画效果
			Duel.HintSelection(g)
			-- 将选中的卡破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 特殊召唤效果处理前检查是否满足条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息为投掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 执行特殊召唤效果处理，若骰子结果为2~5则特殊召唤并设置不能从额外卡组特殊召唤的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让玩家投掷1次骰子
	local d=Duel.TossDice(tp,1)
	if d>1 and d<6 and c:IsRelateToEffect(e)
		-- 判断是否成功特殊召唤该卡
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 创建一个影响自己场上区域的永续效果，禁止从额外卡组特殊召唤怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 限制效果的目标为位于额外卡组的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
