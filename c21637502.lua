--見えざる手ブレアス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：抽卡阶段以外让对方手卡有卡加入的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。把对方手卡随机1张确认。那是怪兽的场合，可以把那只怪兽在自己场上特殊召唤。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 初始化卡片效果，创建三个效果分别为①②③效果
function s.initial_effect(c)
	-- ①：抽卡阶段以外让对方手卡有卡加入的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。把对方手卡随机1张确认。那是怪兽的场合，可以把那只怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 用于判断对方手卡加入的卡是否为对方控制的卡
function s.cfilter(c,tp)
	return c:IsControler(tp)
end
-- 判断当前阶段不是抽卡阶段且对方手卡有卡加入
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方手卡有卡加入的场合
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 设置①效果的发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，准备特殊召唤自己
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行①效果的处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自己特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置③效果的目标判定函数
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 设置②效果的目标判定
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手卡数量大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- 执行②效果的处理流程
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡组
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local tc=hg:RandomSelect(tp,1):GetFirst()
	if not tc then return end
	-- 确认对方手卡中的一张卡
	Duel.ConfirmCards(1-tp,tc)
	-- 判断己方是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 询问玩家是否特殊召唤该怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 将确认的怪兽特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 将对方手卡洗牌
	Duel.ShuffleHand(1-tp)
end
