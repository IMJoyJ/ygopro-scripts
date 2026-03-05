--阿吽の呼吸
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「双天」怪兽加入手卡。
-- ②：自己场上有「双天」效果怪兽存在的场合才能发动。在自己场上把1只「双天魂衍生物」（战士族·光·2星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
function c13764602.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「双天」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13764602+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c13764602.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「双天」效果怪兽存在的场合才能发动。在自己场上把1只「双天魂衍生物」（战士族·光·2星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13764602,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,13764603)
	e2:SetCondition(c13764602.spcon)
	e2:SetTarget(c13764602.sptg)
	e2:SetOperation(c13764602.spop)
	c:RegisterEffect(e2)
end
-- 检索过滤函数，用于筛选「双天」怪兽
function c13764602.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x14f) and c:IsAbleToHand()
end
-- 发动效果处理函数，用于执行①效果
function c13764602.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「双天」怪兽组
	local g=Duel.GetMatchingGroup(c13764602.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的怪兽且玩家选择加入手牌
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(13764602,0)) then  --"是否要加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 特殊召唤条件过滤函数，用于筛选场上的「双天」效果怪兽
function c13764602.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsSetCard(0x14f)
end
-- 特殊召唤发动条件判断函数
function c13764602.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在「双天」效果怪兽
	return Duel.IsExistingMatchingCard(c13764602.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果处理目标设定函数
function c13764602.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13764602.spfilter(chkc,e,tp) end
	-- 判断是否可以特殊召唤衍生物
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	-- 设置操作信息，标记将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息，标记将要产生衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 特殊召唤效果处理函数
function c13764602.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		-- 创建「双天魂衍生物」token
		local token=Duel.CreateToken(tp,13764603)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- ②：自己场上有「双天」效果怪兽存在的场合才能发动。在自己场上把1只「双天魂衍生物」（战士族·光·2星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c13764602.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使玩家在回合结束前不能从额外卡组特殊召唤非融合怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤效果的过滤函数，用于限制非融合怪兽从额外卡组特殊召唤
function c13764602.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
