--ウィッチクラフト・デモンストレーション
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把1只「魔女术」怪兽特殊召唤。这个效果特殊召唤的回合，对方不能对应自己的魔法师族怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
function c70226289.initial_effect(c)
	-- ①：从手卡把1只「魔女术」怪兽特殊召唤。这个效果特殊召唤的回合，对方不能对应自己的魔法师族怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70226289,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_ATTACK+TIMING_END_PHASE)
	e1:SetCountLimit(1,70226289)
	e1:SetTarget(c70226289.target)
	e1:SetOperation(c70226289.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70226289,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,70226289)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c70226289.thcon)
	e2:SetTarget(c70226289.thtg)
	e2:SetOperation(c70226289.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：手卡中可以特殊召唤的「魔女术」怪兽
function c70226289.filter(c,e,tp)
	return c:IsSetCard(0x128) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与合法性检测
function c70226289.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只可以特殊召唤的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c70226289.filter,tp,LOCATION_HAND,0,1,exc,e,tp) end
	-- 设置连锁处理中的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①号效果的实际处理：特殊召唤怪兽并注册限制对方响应的连续效果
function c70226289.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「魔女术」怪兽
	local g=Duel.SelectMatchingCard(tp,c70226289.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功将选中的怪兽以表侧表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的回合，对方不能对应自己的魔法师族怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c70226289.chainop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将限制对方响应的连续效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 连锁处理中的操作：检测到自己发动魔法师族怪兽效果时限制对方的连锁
function c70226289.chainop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前发动效果的卡片的种族
	local race=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE)
	if re:IsActiveType(TYPE_MONSTER) and bit.band(race,RACE_SPELLCASTER)~=0 and ep==tp then
		-- 设定连锁限制，使对方不能对应发动效果
		Duel.SetChainLimit(c70226289.chainlm)
	end
end
-- 连锁限制条件：只有发动效果的玩家自己可以继续连锁
function c70226289.chainlm(e,ep,tp)
	return tp==ep
end
-- 过滤函数：自己场上表侧表示的「魔女术」怪兽
function c70226289.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- ②号效果的发动条件：自己结束阶段且自己场上有「魔女术」怪兽存在
function c70226289.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c70226289.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②号效果的发动准备与合法性检测
function c70226289.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁处理中的操作信息为将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②号效果的实际处理：将这张卡加入手卡
function c70226289.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡因效果加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
