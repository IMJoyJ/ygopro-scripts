--空牙団の疾風 レクス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从手卡把「空牙团的疾风 雷克斯」以外的1只「空牙团」怪兽特殊召唤。那之后，这张卡特殊召唤。
-- ②：「空牙团」卡以外的效果从卡组让卡加入对方手卡的场合，若自己场上有其他的「空牙团」怪兽存在则能发动。自己抽1张。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从手卡把「空牙团的疾风 雷克斯」以外的1只「空牙团」怪兽特殊召唤。那之后，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：「空牙团」卡以外的效果从卡组让卡加入对方手卡的场合，若自己场上有其他的「空牙团」怪兽存在则能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 检查是否公开手牌
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤满足条件的「空牙团」怪兽（不包括自身）
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动①效果
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判断玩家是否可以特殊召唤两次
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤2张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 执行①效果的处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤到场上
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		and c:IsRelateToChain() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤从卡组加入手牌的卡（控制者为对方）
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 判断是否满足②效果发动条件
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp) and re and not re:GetHandler():IsSetCard(0x114)
end
-- 过滤场上的「空牙团」怪兽
function s.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- 判断是否可以发动②效果
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽一张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 判断场上是否存在「空牙团」怪兽
		and Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 设置目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置操作信息，表示将要抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行②效果的处理流程
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
