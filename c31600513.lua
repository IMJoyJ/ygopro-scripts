--プレイング・マンティス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己准备阶段才能发动。在自己场上把1只「小螳螂衍生物」（昆虫族·风·1星·攻/守500）特殊召唤。
-- ②：1回合1次，对方怪兽的攻击宣言时，把自己的魔法与陷阱区域1张卡送去墓地才能发动。那只对方怪兽回到持有者手卡。
-- ③：把墓地的这张卡除外才能发动。在自己场上把1只「小螳螂衍生物」特殊召唤。
function c31600513.initial_effect(c)
	-- ①：自己准备阶段才能发动。在自己场上把1只「小螳螂衍生物」（昆虫族·风·1星·攻/守500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31600513,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1,31600513)
	e1:SetCondition(c31600513.tkcon)
	e1:SetTarget(c31600513.tktg)
	e1:SetOperation(c31600513.tkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方怪兽的攻击宣言时，把自己的魔法与陷阱区域1张卡送去墓地才能发动。那只对方怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31600513,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1)
	e2:SetCondition(c31600513.thcon)
	e2:SetCost(c31600513.thcost)
	e2:SetTarget(c31600513.thtg)
	e2:SetOperation(c31600513.thop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。在自己场上把1只「小螳螂衍生物」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,31600514)
	-- 将这张卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c31600513.tktg)
	e3:SetOperation(c31600513.tkop)
	c:RegisterEffect(e3)
end
-- 效果适用条件：当前回合玩家为使用者
function c31600513.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为使用者
	return Duel.GetTurnPlayer()==tp
end
-- 效果适用条件：场上存在空位且可以特殊召唤衍生物
function c31600513.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31600514,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) end
	-- 设置连锁操作信息：将召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息：将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：若场上存在空位且可以特殊召唤衍生物，则召唤衍生物
function c31600513.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上不存在空位则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若可以特殊召唤衍生物则执行召唤
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31600514,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) then
		-- 创建衍生物
		local token=Duel.CreateToken(tp,31600514)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果适用条件：当前回合玩家不是使用者
function c31600513.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是使用者
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数：可送入墓地的魔法与陷阱卡
function c31600513.cfilter(c)
	return c:IsAbleToGraveAsCost() and c:GetSequence()<5
end
-- 效果处理：选择一张魔法与陷阱卡送入墓地作为cost
function c31600513.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的魔法与陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c31600513.cfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示选择要送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张魔法与陷阱卡送入墓地
	local g=Duel.SelectMatchingCard(tp,c31600513.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡送入墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理：设置将攻击怪兽送回手牌的操作信息
function c31600513.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	if chk==0 then return tc and tc:IsAbleToHand() end
	-- 设置将攻击怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- 效果处理：将攻击怪兽送回手牌
function c31600513.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		-- 将攻击怪兽送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
