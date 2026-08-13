--スケアクロー・ライトハート
-- 效果：
-- 「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」1只
-- 这张卡连接召唤的场合，若非自己的主要怪兽区域的怪兽则不能作为连接素材。这个卡名的②的效果在决斗中只能使用1次。
-- ①：这张卡在额外怪兽区域连接召唤的场合才能发动。从卡组把1张「肆世坏-恐惧世界」加入手卡。
-- ②：自己场上有「维萨斯-斯塔弗罗斯特」存在的场合才能发动。这张卡从墓地特殊召唤。
function c53776969.initial_effect(c)
	-- 将「维萨斯-斯塔弗罗斯特」(56099748)和「肆世坏-恐惧世界」(56063182)登记为本卡记载的卡名，供相关效果判定使用。
	aux.AddCodeList(c,56099748,56063182)
	-- 为本卡添加连接召唤手续：素材必须为1只满足mfilter的怪兽（即「恐吓爪牙族」怪兽或「维萨斯-斯塔弗罗斯特」），且该素材必须位于我方主要怪兽区域。
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
	-- ②：自己场上有「维萨斯-斯塔弗罗斯特」存在的场合才能发动。这张卡从墓地特殊召唤。（这个卡名的②的效果在决斗中只能使用1次。）
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
-- 定义连接素材的筛选条件：素材须为「恐吓爪牙族」怪兽或「维萨斯-斯塔弗罗斯特」，且位于我方主要怪兽区域（GetSequence()<5），实现‘非自己的主要怪兽区域的怪兽不能作为连接素材’。
function c53776969.mfilter(c)
	return (c:IsLinkSetCard(0x17a) or c:IsLinkCode(56099748))
		and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- ①效果的发动条件：本卡以连接召唤方式特殊召唤成功，且召唤后所在位置是额外怪兽区域（序位>4）。
function c53776969.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetSequence()>4
end
-- 定义①效果检索对象的过滤条件：卡名为「肆世坏-恐惧世界」，且可以加入手卡。
function c53776969.thfilter(c)
	return c:IsCode(56063182) and c:IsAbleToHand()
end
-- ①效果发动时进行合法性检查并设定操作信息：确认卡组中存在「肆世坏-恐惧世界」，并声明本效果将从卡组把1张卡加入手卡。
function c53776969.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在不发动处理的检查阶段（chk==0），确认卡组是否存在至少1张符合条件的「肆世坏-恐惧世界」。
	if chk==0 then return Duel.IsExistingMatchingCard(c53776969.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将当前连锁操作信息登记为‘从卡组将1张卡加入手卡’，用于其他效果（如星尘龙等）的联动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：玩家选择1张「肆世坏-恐惧世界」加入手卡，并向对方展示确认。
function c53776969.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「肆世坏-恐惧世界」作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c53776969.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将被选择的卡以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果判定用的过滤器：场上存在表侧表示的「维萨斯-斯塔弗罗斯特」。
function c53776969.filter(c)
	return c:IsCode(56099748) and c:IsFaceup()
end
-- ②效果的发动条件：自己场上有表侧表示的「维萨斯-斯塔弗罗斯特」存在。
function c53776969.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「维萨斯-斯塔弗罗斯特」。
	return Duel.IsExistingMatchingCard(c53776969.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②效果发动时进行合法性检查并设定操作信息：确认我方主要怪兽区域有空位，且本卡可以特殊召唤；设定将本卡特殊召唤的操作信息。
function c53776969.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在不发动处理的检查阶段（chk==0），先确认我方主要怪兽区域是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将连锁操作信息登记为‘特殊召唤本卡’，供其他效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：若本卡与效果仍有关联，则将本卡从墓地特殊召唤到我方场上。
function c53776969.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示将本卡特殊召唤到控制者（我方）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
