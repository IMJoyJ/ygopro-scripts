--プレイング・マンティス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己准备阶段才能发动。在自己场上把1只「小螳螂衍生物」（昆虫族·风·1星·攻/守500）特殊召唤。
-- ②：1回合1次，对方怪兽的攻击宣言时，把自己的魔法与陷阱区域1张卡送去墓地才能发动。那只对方怪兽回到持有者手卡。
-- ③：把墓地的这张卡除外才能发动。在自己场上把1只「小螳螂衍生物」特殊召唤。
function c31600513.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己准备阶段才能发动。在自己场上把1只「小螳螂衍生物」（昆虫族·风·1星·攻/守500）特殊召唤。
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
	-- 将③效果的发动代价设定为：除外墓地中的这张卡（aux.bfgcost为通用代价函数，负责检查并执行除外）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c31600513.tktg)
	e3:SetOperation(c31600513.tkop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判定函数：仅在当前回合玩家是此卡控制者（即自己的准备阶段）时允许发动。
function c31600513.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为tp，用于满足“自己准备阶段才能发动”的时机条件。
	return Duel.GetTurnPlayer()==tp
end
-- ①/③效果的发动目标合法性判定：自己主要怪兽区有空位，且自己可以特殊召唤“小螳螂衍生物”（昆虫族·风·1星·攻/守500）。
function c31600513.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区当前是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否特殊召唤卡号31600514的“小螳螂衍生物”（昆虫族·风·1星·攻/守500）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31600514,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) end
	-- 设置本次效果处理将生成衍生物的操作信息，供需要检测衍生物产生的效果使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次效果处理将进行特殊召唤的操作信息，供需要检测特殊召唤的效果使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①/③效果的实际处理：若满足条件，则在己方场上特殊召唤1只“小螳螂衍生物”。
function c31600513.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若己方主要怪兽区没有空位，则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认己方能够特殊召唤该衍生物，否则不进行处理。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31600514,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) then
		-- 创建1只“小螳螂衍生物”（卡号31600514）的衍生物。
		local token=Duel.CreateToken(tp,31600514)
		-- 将该衍生物以表侧表示特殊召唤到tp的场上（主要怪兽区）。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件判定函数：当前回合玩家不是此卡控制者，即对方回合，以对应“对方怪兽攻击宣言时”。
function c31600513.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否不等于tp，用于确认攻击宣言来自对方的回合。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果代价的过滤函数：选取自己通常魔法与陷阱区域（序号0-4，不含场地魔法区和灵摆区域）中1张可作为代价送去墓地的卡。
function c31600513.cfilter(c)
	return c:IsAbleToGraveAsCost() and c:GetSequence()<5
end
-- ②效果的发动代价：从己方魔陷区选择1张符合条件的卡送去墓地，支付代价后才能发动。
function c31600513.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段（chk==0）确认己方魔陷区存在至少1张可送去墓地作为代价的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c31600513.cfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 向玩家显示选择提示，要求选择一张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让tp从自己的魔法与陷阱区域选择1张满足cfilter条件的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c31600513.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡送去墓地，理由为代价（REASON_COST），完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标判定：以攻击宣言的怪兽作为效果处理对象，并确认其可以被加入手牌；随后设置回手牌的操作信息。
function c31600513.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击宣言的怪兽。
	local tc=Duel.GetAttacker()
	if chk==0 then return tc and tc:IsAbleToHand() end
	-- 设置本次效果处理的信息为将那只攻击怪兽返回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- ②效果处理：若攻击宣言的怪兽仍与此战斗相关且控制者为对手，则将其返回持有者手牌。
function c31600513.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时获取当前攻击宣言的怪兽。
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		-- 将那只攻击怪兽返回持有者手牌，原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
