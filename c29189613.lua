--アロマガーデニング
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己对「芳香」怪兽的召唤·特殊召唤成功的场合才能发动。自己回复1000基本分。
-- ②：自己基本分比对方少的场合，对方怪兽的攻击宣言时才能发动。从卡组把1只「芳香」怪兽特殊召唤。
function c29189613.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己对「芳香」怪兽的召唤·特殊召唤成功的场合才能发动。自己回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29189613,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,29189613)
	e2:SetCondition(c29189613.reccon)
	e2:SetTarget(c29189613.rectg)
	e2:SetOperation(c29189613.recop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己基本分比对方少的场合，对方怪兽的攻击宣言时才能发动。从卡组把1只「芳香」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29189613,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCountLimit(1,29189614)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c29189613.spcon)
	e4:SetTarget(c29189613.sptg)
	e4:SetOperation(c29189613.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断是否为己方场上表侧表示的「芳香」怪兽
function c29189613.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSetCard(0xc9)
end
-- 条件函数，判断是否有己方「芳香」怪兽被召唤或特殊召唤成功
function c29189613.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29189613.cfilter,1,nil,tp)
end
-- 设置效果目标玩家为使用者，设置效果目标参数为1000，设置效果处理信息为回复1000基本分
function c29189613.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果目标玩家为使用者
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数为1000
	Duel.SetTargetParam(1000)
	-- 设置效果处理信息为回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果处理函数，使目标玩家回复1000基本分
function c29189613.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复目标参数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 条件函数，判断是否满足②效果发动条件：对方怪兽攻击宣言且使用者基本分少于对方
function c29189613.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方怪兽攻击宣言且使用者基本分少于对方
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 过滤函数，用于筛选可以特殊召唤的「芳香」怪兽
function c29189613.spfilter(c,e,tp)
	return c:IsSetCard(0xc9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，判断是否满足发动条件：己方场上存在空位且卡组存在可特殊召唤的「芳香」怪兽
function c29189613.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的「芳香」怪兽
		and Duel.IsExistingMatchingCard(c29189613.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息为从卡组特殊召唤1只「芳香」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，从卡组选择1只「芳香」怪兽特殊召唤
function c29189613.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场地魔法是否仍然存在于场，以及己方场上是否存在空位
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示使用者选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只「芳香」怪兽
	local g=Duel.SelectMatchingCard(tp,c29189613.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
