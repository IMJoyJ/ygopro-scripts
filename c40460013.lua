--炎魔の触媒
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只恶魔族怪兽给对方观看才能发动。那2只之内的1只特殊召唤，另1只丢弃。
-- ②：这张卡在墓地存在的状态，自己的恶魔族怪兽的战斗让怪兽被破坏时才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果，①为起动效果，②为场上的诱发效果
function c40460013.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1只恶魔族怪兽给对方观看才能发动。那2只之内的1只特殊召唤，另1只丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,40460013)
	e1:SetTarget(c40460013.sptg)
	e1:SetOperation(c40460013.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的恶魔族怪兽的战斗让怪兽被破坏时才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,40460013+o)
	e2:SetCondition(c40460013.thcon)
	e2:SetTarget(c40460013.thtg)
	e2:SetOperation(c40460013.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的手卡恶魔族怪兽，可以被丢弃或特殊召唤
function c40460013.cfilter(c,e,tp,b1,b2)
	return c:IsRace(RACE_FIEND) and not c:IsPublic()
		and (b1 and c:IsDiscardable() or b2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ①效果的发动条件判断和处理，检查是否满足发动条件并选择目标
function c40460013.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=c:IsDiscardable()
	if chk==0 then
		if c:IsPublic() then return false end
		-- 判断场上是否有足够的怪兽区域进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if not b1 and not b2 then return false end
		-- 检查手牌中是否存在满足条件的恶魔族怪兽
		return Duel.IsExistingMatchingCard(c40460013.cfilter,tp,LOCATION_HAND,0,1,c,e,tp,b1,b2)
	end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的恶魔族怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,c40460013.cfilter,tp,LOCATION_HAND,0,1,1,c,e,tp,b1,b2)
	local tc=g:GetFirst()
	-- 设置当前处理的连锁对象为所选的怪兽
	Duel.SetTargetCard(tc)
	-- 向对方确认所选怪兽的卡面
	Duel.ConfirmCards(1-tp,tc)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息，表示将要丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 过滤函数，用于筛选可以被特殊召唤的怪兽
function c40460013.checkfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理，选择特殊召唤的卡并处理其余卡
function c40460013.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	local mg=Group.FromCards(c,tc)
	-- 判断所选卡是否仍然有效并满足特殊召唤条件
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=mg:FilterSelect(tp,c40460013.checkfilter,1,1,nil,e,tp)
		if #sg==0 then return end
		mg:RemoveCard(sg:GetFirst())
		-- 将所选卡特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		-- 将剩余的卡送去墓地
		Duel.SendtoGrave(mg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- ②效果的发动条件判断，检查是否为己方恶魔族怪兽被战斗破坏
function c40460013.thcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsControler(tp)
		and rc:IsFaceup() and rc:IsRace(RACE_FIEND)
end
-- ②效果的发动条件判断，检查是否可以将卡加入手牌
function c40460013.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②效果的处理，将卡加入手牌
function c40460013.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
