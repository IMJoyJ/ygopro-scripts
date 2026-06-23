--Couple of Aces
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。进行1次投掷硬币。表的场合，这张卡在自己场上特殊召唤。里的场合，这张卡在对方场上特殊召唤。
-- ②：这张卡的①的效果特殊召唤成功的场合发动。自己从卡组抽2张。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①投掷硬币特殊召唤效果和②特殊召唤成功后抽卡效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。进行1次投掷硬币。表的场合，这张卡在自己场上特殊召唤。里的场合，这张卡在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤成功的场合发动。自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 判断是否满足特殊召唤条件，检查自己或对方场上是否有空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空位且该卡可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查对方场上是否有空位且该卡可特殊召唤到对方场上
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	-- 设置操作信息为投掷硬币效果
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 设置操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行投掷硬币并根据结果将卡特殊召唤到自己或对方场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 进行一次硬币投掷
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		-- 将卡特殊召唤到自己场上
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
	if coin==0 then
		-- 将卡特殊召唤到对方场上
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 判断该卡是否为通过①效果特殊召唤成功
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置抽卡效果的目标玩家和抽卡数量
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的抽卡数量为2
	Duel.SetTargetParam(2)
	-- 设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行抽卡效果
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
