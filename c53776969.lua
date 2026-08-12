--スケアクロー・ライトハート
-- 效果：
-- 「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」1只
-- 这张卡连接召唤的场合，若非自己的主要怪兽区域的怪兽则不能作为连接素材。这个卡名的②的效果在决斗中只能使用1次。
-- ①：这张卡在额外怪兽区域连接召唤的场合才能发动。从卡组把1张「肆世坏-恐惧世界」加入手卡。
-- ②：自己场上有「维萨斯-斯塔弗罗斯特」存在的场合才能发动。这张卡从墓地特殊召唤。
function c53776969.initial_effect(c)
	-- 注册卡片代码列表，记录该卡与「维萨斯-斯塔弗罗斯特」和「肆世坏-恐惧世界」的关联
	aux.AddCodeList(c,56099748,56063182)
	-- 设置连接召唤手续，要求使用1张满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c53776969.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡在额外怪兽区域连接召唤的场合才能发动。从卡组把1张「肆世坏-恐惧世界」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c53776969.thcon)
	e1:SetTarget(c53776969.thtg)
	e1:SetOperation(c53776969.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「维萨斯-斯塔弗罗斯特」存在的场合才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,53776969+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c53776969.spcon)
	e2:SetTarget(c53776969.sptg)
	e2:SetOperation(c53776969.spop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数，筛选「恐吓爪牙族」或「维萨斯-斯塔弗罗斯特」且在主要怪兽区域的怪兽
function c53776969.mfilter(c)
	return (c:IsLinkSetCard(0x17a) or c:IsLinkCode(56099748))
		and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- 效果发动条件判断，确认该卡是通过连接召唤且在额外怪兽区域
function c53776969.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetSequence()>4
end
-- 检索过滤函数，筛选「肆世坏-恐惧世界」且可以加入手牌
function c53776969.thfilter(c)
	return c:IsCode(56063182) and c:IsAbleToHand()
end
-- 设置效果处理信息，准备从卡组检索并加入手牌
function c53776969.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中存在「肆世坏-恐惧世界」
	if chk==0 then return Duel.IsExistingMatchingCard(c53776969.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把「肆世坏-恐惧世界」加入手牌并确认
function c53776969.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「肆世坏-恐惧世界」
	local g=Duel.SelectMatchingCard(tp,c53776969.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 墓地特殊召唤条件过滤函数，筛选场上存在的「维萨斯-斯塔弗罗斯特」
function c53776969.filter(c)
	return c:IsCode(56099748) and c:IsFaceup()
end
-- 判断是否满足墓地特殊召唤条件，即自己场上存在「维萨斯-斯塔弗罗斯特」
function c53776969.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「维萨斯-斯塔弗罗斯特」
	return Duel.IsExistingMatchingCard(c53776969.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置墓地特殊召唤的目标和条件
function c53776969.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，准备将该卡特殊召唤到场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地特殊召唤效果处理函数，将该卡特殊召唤到场上
function c53776969.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
