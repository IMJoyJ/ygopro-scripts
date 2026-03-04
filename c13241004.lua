--ファーニマル・ペンギン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只在这张卡在场上表侧表示存在才有1次，自己主要阶段才能发动。从手卡把「毛绒动物·企鹅」以外的1只「毛绒动物」怪兽特殊召唤。
-- ②：这张卡成为「魔玩具」融合怪兽的融合召唤的素材送去墓地的场合才能发动。自己从卡组抽2张，那之后选1张手卡丢弃。
function c13241004.initial_effect(c)
	-- ①：只在这张卡在场上表侧表示存在才有1次，自己主要阶段才能发动。从手卡把「毛绒动物·企鹅」以外的1只「毛绒动物」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13241004,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c13241004.sptg)
	e1:SetOperation(c13241004.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡成为「魔玩具」融合怪兽的融合召唤的素材送去墓地的场合才能发动。自己从卡组抽2张，那之后选1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13241004,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,13241004)
	e2:SetCondition(c13241004.drcon)
	e2:SetTarget(c13241004.drtg)
	e2:SetOperation(c13241004.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在满足条件的「毛绒动物」怪兽（不包括企鹅本身）
function c13241004.spfilter(c,e,tp)
	return c:IsSetCard(0xa9) and not c:IsCode(13241004) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件
function c13241004.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡中是否存在满足条件的「毛绒动物」怪兽
		and Duel.IsExistingMatchingCard(c13241004.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的处理函数，用于执行效果内容
function c13241004.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只「毛绒动物」怪兽
	local g=Duel.SelectMatchingCard(tp,c13241004.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足效果发动条件的函数
function c13241004.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and c:GetReasonCard():IsSetCard(0xad)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件
function c13241004.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置效果处理时要抽卡的信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置效果处理时要丢弃手卡的信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果发动时的处理函数，用于执行效果内容
function c13241004.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作并判断是否成功抽到2张卡
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 将玩家手卡洗牌
		Duel.ShuffleHand(p)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让玩家丢弃1张手卡
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
