--光の天穿バハルティヤ
-- 效果：
-- 这张卡可以把1只效果怪兽解放作上级召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡在手卡存在，对方主要阶段对方用抽卡以外的方法从卡组把卡加入手卡的场合才能发动。这张卡上级召唤。
-- ②：这张卡从手卡的召唤·特殊召唤成功的场合才能发动。对方把自身手卡数量的卡从卡组上面里侧表示除外。那之后，对方让手卡全部回到卡组，这个效果除外的卡加入手卡。
function c53318263.initial_effect(c)
	-- 这张卡可以把1只效果怪兽解放作上级召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53318263,0))  --"把1只效果怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c53318263.rlcon)
	e1:SetOperation(c53318263.rlop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- 对方主要阶段对方用抽卡以外的方法从卡组把卡加入手卡的场合才能发动。这张卡上级召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53318263,1))
	e3:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c53318263.sumcon)
	e3:SetTarget(c53318263.sumtg)
	e3:SetOperation(c53318263.sumop)
	c:RegisterEffect(e3)
	-- 这张卡从手卡的召唤·特殊召唤成功的场合才能发动。对方把自身手卡数量的卡从卡组上面里侧表示除外。那之后，对方让手卡全部回到卡组，这个效果除外的卡加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53318263,2))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,53318263)
	e4:SetTarget(c53318263.thtg)
	e4:SetOperation(c53318263.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c53318263.thcon)
	c:RegisterEffect(e5)
end
-- 过滤函数，返回场上所有效果怪兽
function c53318263.rlfilter(c)
	return c:IsType(TYPE_EFFECT)
end
-- 判断是否满足上级召唤条件：等级不低于6，最少需要1个祭品，且场上存在满足条件的祭品
function c53318263.rlcon(e,c,minc)
	if c==nil then return true end
	-- 获取场上所有效果怪兽作为祭品候选
	local mg=Duel.GetMatchingGroup(c53318263.rlfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查是否满足上级召唤条件
	return c:IsLevelAbove(6) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 处理上级召唤时的祭品选择和解放操作
function c53318263.rlop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有效果怪兽作为祭品候选
	local mg=Duel.GetMatchingGroup(c53318263.rlfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 从场上选择1个祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的祭品进行解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数，返回对方从卡组加入手卡且非因抽卡原因的卡
function c53318263.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
-- 判断是否满足上级召唤触发条件：当前回合玩家为对方，且有对方从卡组加入手卡的卡，且当前阶段为主阶段1或主阶段2
function c53318263.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查是否满足上级召唤触发条件
	return Duel.GetTurnPlayer()==1-tp and eg:IsExists(c53318263.cfilter,1,nil,1-tp) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 设置上级召唤效果的目标信息
function c53318263.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1) end
	-- 设置上级召唤效果的目标为召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
-- 处理上级召唤效果的发动和选择召唤方式
function c53318263.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local pos=0
	if c:IsSummonable(true,nil,1) then pos=pos+POS_FACEUP_ATTACK end
	if c:IsMSetable(true,nil,1) then pos=pos+POS_FACEDOWN_DEFENSE end
	if pos==0 then return end
	-- 判断玩家是否选择了攻击表示
	if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
		-- 进行通常召唤操作
		Duel.Summon(tp,c,true,nil,1)
	else
		-- 进行盖放操作
		Duel.MSet(tp,c,true,nil,1)
	end
end
-- 判断该卡是否从手卡被召唤或特殊召唤成功
function c53318263.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 设置上级召唤效果的目标信息和条件检查
function c53318263.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方手卡组
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local ct=#hg
	-- 获取对方卡组最上方的卡
	local dg=Duel.GetDecktopGroup(1-tp,ct)
	if chk==0 then return ct>0 and dg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==ct
		and hg:FilterCount(Card.IsAbleToDeck,nil)==ct end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息：将对方卡组最上方的卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,ct,1-tp,LOCATION_DECK)
	-- 设置连锁操作信息：将己方手卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,hg,ct,0,0)
end
-- 处理上级召唤成功后的效果发动
function c53318263.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家的手卡组
	local hg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	local ct=#hg
	-- 获取目标玩家卡组最上方的卡
	local dg=Duel.GetDecktopGroup(p,ct)
	-- 检查是否满足效果发动条件：对方手卡数量大于0，且卡组最上方的卡可以除外
	if ct>0 and dg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==ct and Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)==ct then
		-- 中断当前效果处理流程
		Duel.BreakEffect()
		-- 获取之前操作实际操作的卡片组
		local og=Duel.GetOperatedGroup()
		-- 将己方手卡送回卡组并洗牌
		if Duel.SendtoDeck(hg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			-- 将之前除外的卡送入手卡
			Duel.SendtoHand(og,p,REASON_EFFECT)
		end
	end
end
