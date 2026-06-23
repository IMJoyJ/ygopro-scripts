--古代の機械像
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放才能发动。除「古代的机械像」外的1只「古代的机械巨人」或者有那个卡名记述的怪兽从手卡·卡组无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①手牌特殊召唤条件；②场上的起动效果
function s.initial_effect(c)
	-- 记录该卡效果文本记载着「古代的机械巨人」的卡号
	aux.AddCodeList(c,83104731)
	-- 效果①：设置手牌特殊召唤的规则，限制1回合只能发动1次，条件为对方怪兽数量大于己方
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 效果②：设置场上的起动效果，限制1回合只能发动1次，需要解放自身作为代价
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件函数，判断是否满足手牌特殊召唤的条件
function s.spcon(e,c)
	if c==nil then return true end
	-- 判断己方场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断己方怪兽数量小于对方怪兽数量
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)
end
-- 效果②的发动代价函数，判断是否可以解放自身
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤目标卡的过滤函数，筛选「古代的机械巨人」或其相关卡
function s.spfilter(c,e,tp)
	-- 过滤条件：卡名为「古代的机械巨人」或效果文本记载该卡名，且为怪兽卡，不是自身，可特殊召唤
	return (c:IsCode(83104731) or aux.IsCodeListed(c,83104731)) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动目标函数，判断是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 判断手牌或卡组中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1张手牌或卡组中的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的发动处理函数，执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的1张卡
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
