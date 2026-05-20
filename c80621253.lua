--マナドゥム・トリッド
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「末那愚子族」调整特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的效果
function s.initial_effect(c)
	-- 将「维萨斯-斯塔弗罗斯特」加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,56099748)
	-- ①：自己场上有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，这张卡可以从手卡特殊召唤。这个卡名的①的方法的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"自己场上有特定怪兽存在的场合，这张卡可以从手卡特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「末那愚子族」调整特殊召唤。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽
function s.filter(c)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100) and c:IsType(TYPE_MONSTER)
	return c:IsFaceup() and (b1 or b2)
end
-- 手卡特殊召唤规则的条件判定函数
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 判定这张卡是否因战斗或效果而被破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤条件：卡组中可以特殊召唤的「末那愚子族」调整怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x190) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（Target）函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的效果处理（Operation）函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「末那愚子族」调整怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
