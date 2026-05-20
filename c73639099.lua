--セラの蟲惑魔
-- 效果：
-- 连接怪兽以外的「虫惑魔」怪兽1只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：连接召唤的这张卡不受陷阱卡的效果影响。
-- ②：通常陷阱卡发动的场合才能发动。同名卡不在自己场上存在的1只「虫惑魔」怪兽从卡组特殊召唤。
-- ③：这张卡以外的自己的「虫惑魔」怪兽的效果发动的场合才能发动。从卡组把1张「洞」通常陷阱卡或「落穴」通常陷阱卡在自己场上盖放。
function c73639099.initial_effect(c)
	-- 设置连接召唤的手续，需要1只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c73639099.matfilter,1,1)
	c:EnableReviveLimit()
	-- ①：连接召唤的这张卡不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c73639099.imcon)
	e1:SetValue(c73639099.efilter)
	c:RegisterEffect(e1)
	-- ②：通常陷阱卡发动的场合才能发动。同名卡不在自己场上存在的1只「虫惑魔」怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73639099,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,73639099)
	e3:SetCondition(c73639099.spcon)
	e3:SetTarget(c73639099.sptg)
	e3:SetOperation(c73639099.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡以外的自己的「虫惑魔」怪兽的效果发动的场合才能发动。从卡组把1张「洞」通常陷阱卡或「落穴」通常陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(73639099,1))  --"盖放陷阱"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,73639100)
	e4:SetCondition(c73639099.setcon)
	e4:SetTarget(c73639099.settg)
	e4:SetOperation(c73639099.setop)
	c:RegisterEffect(e4)
end
-- 连接素材过滤：连接怪兽以外的「虫惑魔」怪兽
function c73639099.matfilter(c)
	return c:IsLinkSetCard(0x108a) and not c:IsLinkType(TYPE_LINK)
end
-- 免疫效果的启用条件：这张卡是连接召唤的
function c73639099.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 免疫效果的过滤：不受陷阱卡的效果影响
function c73639099.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
-- 特殊召唤效果的发动条件：通常陷阱卡发动时
function c73639099.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():GetType()==TYPE_TRAP
end
-- 过滤场上表侧表示且卡名与指定卡名相同的卡
function c73639099.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 过滤卡组中可以特殊召唤，且同名卡不在自己场上存在的「虫惑魔」怪兽
function c73639099.spfilter(c,e,tp)
	return c:IsSetCard(0x108a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在与该卡同名的卡
		and not Duel.IsExistingMatchingCard(c73639099.cfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- 特殊召唤效果的靶向/发动准备函数
function c73639099.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特殊召唤条件的「虫惑魔」怪兽
		and Duel.IsExistingMatchingCard(c73639099.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤的操作信息，表示从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理函数
function c73639099.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「虫惑魔」怪兽
	local g=Duel.SelectMatchingCard(tp,c73639099.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 盖放陷阱效果的发动条件：这张卡以外的自己的「虫惑魔」怪兽的效果发动时
function c73639099.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc~=c and rc:IsSetCard(0x108a) and rc:IsControler(tp)
end
-- 过滤卡组中可以盖放的「洞」通常陷阱卡或「落穴」通常陷阱卡
function c73639099.setfilter(c)
	return c:IsSetCard(0x4c,0x89) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 盖放陷阱效果的靶向/发动准备函数
function c73639099.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可盖放的「洞」或「落穴」通常陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c73639099.setfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 盖放陷阱效果的处理函数
function c73639099.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足条件的通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,c73639099.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的陷阱卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
