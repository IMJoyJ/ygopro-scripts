--カラクリ大将軍 無零怒
-- 效果：
-- 调整＋调整以外的机械族怪兽1只以上
-- ①：这张卡同调召唤成功时才能发动。从卡组把1只「机巧」怪兽特殊召唤。
-- ②：1回合1次，自己场上的表侧表示的「机巧」怪兽的表示形式变更的场合发动。自己从卡组抽1张。
function c66976526.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的机械族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_MACHINE),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时才能发动。从卡组把1只「机巧」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66976526,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c66976526.spcon)
	e1:SetTarget(c66976526.sptg)
	e1:SetOperation(c66976526.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上的表侧表示的「机巧」怪兽的表示形式变更的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66976526,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c66976526.drcon)
	e2:SetTarget(c66976526.drtg)
	e2:SetOperation(c66976526.drop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否是通过同调召唤方式特殊召唤成功
function c66976526.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中可以特殊召唤的「机巧」怪兽
function c66976526.spfilter(c,e,tp)
	return c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与合法性检查
function c66976526.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只可以特殊召唤的「机巧」怪兽
		and Duel.IsExistingMatchingCard(c66976526.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示此效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行逻辑
function c66976526.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无空余怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「机巧」怪兽
	local g=Duel.SelectMatchingCard(tp,c66976526.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表示形式发生变更（攻击表示与守备表示互相切换）的表侧表示「机巧」怪兽
function c66976526.cfilter(c,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsSetCard(0x11) and c:IsControler(tp) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1))
end
-- 检查是否有自己场上的表侧表示「机巧」怪兽变更了表示形式
function c66976526.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66976526.cfilter,1,nil,tp)
end
-- 抽卡效果的发动准备与合法性检查
function c66976526.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡当前是否未在连锁中，且自己是否可以抽卡
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的参数为1张
	Duel.SetTargetParam(1)
	-- 设置连锁处理的操作信息，表示此效果会让玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行逻辑
function c66976526.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
