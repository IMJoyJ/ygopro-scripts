--見えざる手ブレアス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：抽卡阶段以外让对方手卡有卡加入的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。把对方手卡随机1张确认。那是怪兽的场合，可以把那只怪兽在自己场上特殊召唤。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 初始化卡片的三个效果：①从手卡特殊召唤的诱发效果、③战斗破坏抗性的永续效果、②确认并可能特殊召唤对方手卡怪兽的起动效果。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：抽卡阶段以外让对方手卡有卡加入的场合才能发动。这张卡从手卡特殊召唤。
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
-- 过滤函数：判断卡片c是否由指定玩家tp控制，用于筛选出对方手卡加入的卡。
function s.cfilter(c,tp)
	return c:IsControler(tp)
end
-- ①效果的发动条件：当前不是抽卡阶段，且本次加入手卡的卡中存在由对方玩家控制的卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段不是抽卡阶段，且加入手卡的卡组eg中至少存在1张由对方玩家控制的卡。
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- ①效果的发动合法性检查（chk==0）：自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本次效果处理包含特殊召唤，对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与当前连锁关联，则将其从手卡特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 以表侧表示将这张卡特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的适用对象判定：自身或自身当前的战斗对象，使二者不会被那次战斗破坏。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- ②效果的发动条件检查：对方手卡中存在至少1张卡。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方手卡中至少存在1张卡，满足②效果的发动条件。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- ②效果处理：获取对方手卡并随机选择1张；若没有可选卡则结束；向对方玩家展示该卡；若自己怪兽区有空位、该卡可特殊召唤且玩家选择是，则将其特殊召唤到自己场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡中的所有卡，生成候选组hg。
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local tc=hg:RandomSelect(tp,1):GetFirst()
	if not tc then return end
	-- 向对方玩家展示随机选中的那张卡，完成手牌确认。
	Duel.ConfirmCards(1-tp,tc)
	-- 判断自己场上主要怪兽区是否有可用空格，作为能否特殊召唤的条件。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 满足前两个条件后，询问自己玩家是否选择将那只怪兽特殊召唤到自己的场上。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 将随机选中的对方手卡怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 洗切对方手卡，使手牌重新随机排序。
	Duel.ShuffleHand(1-tp)
end
