--天威の龍仙女
-- 效果：
-- 幻龙族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡，以自己墓地1只幻龙族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不能把「天威」怪兽以外的从额外卡组特殊召唤的场上的怪兽的效果发动。
-- ②：效果怪兽以外的自己的表侧表示怪兽进行战斗的攻击宣言时，以对方场上1张卡为对象才能发动。那张卡破坏。
function c78917791.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要2只幻龙族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WYRM),2,2)
	-- ①：丢弃1张手卡，以自己墓地1只幻龙族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不能把「天威」怪兽以外的从额外卡组特殊召唤的场上的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78917791,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,78917791)
	e1:SetCost(c78917791.spcost)
	e1:SetTarget(c78917791.sptg)
	e1:SetOperation(c78917791.spop)
	c:RegisterEffect(e1)
	-- ②：效果怪兽以外的自己的表侧表示怪兽进行战斗的攻击宣言时，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78917791,1))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,78917792)
	e2:SetCondition(c78917791.atkcon)
	e2:SetTarget(c78917791.atktg)
	e2:SetOperation(c78917791.atkop)
	c:RegisterEffect(e2)
end
-- ①号效果的Cost（发动代价）函数：丢弃1张手卡
function c78917791.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤可以特殊召唤的墓地幻龙族怪兽
function c78917791.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsRace(RACE_WYRM)
end
-- ①号效果的Target（发动准备/对象选择）函数
function c78917791.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c78917791.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 检查自己墓地是否存在可以特殊召唤的幻龙族怪兽
		and Duel.IsExistingTarget(c78917791.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的幻龙族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c78917791.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，包含特殊召唤分类和目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果的Operation（效果处理）函数
function c78917791.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把「天威」怪兽以外的从额外卡组特殊召唤的场上的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c78917791.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数：判定是否为「天威」怪兽以外的、从额外卡组特殊召唤的场上怪兽的效果发动
function c78917791.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsOnField()
		and rc:IsSummonLocation(LOCATION_EXTRA) and not rc:IsSetCard(0x12c)
end
-- ②号效果的Condition（发动条件）函数
function c78917791.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击宣言的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将目标切换为被攻击的自己怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsFaceup() and tc:IsControler(tp) and not tc:IsType(TYPE_EFFECT)
end
-- ②号效果的Target（发动准备/对象选择）函数
function c78917791.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息，包含破坏分类和目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②号效果的Operation（效果处理）函数
function c78917791.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要破坏的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
