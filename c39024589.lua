--魔界劇団－ダンディ・バイプレイヤー
-- 效果：
-- ←8 【灵摆】 8→
-- ①：自己灵摆召唤成功时才能发动。从自己的额外卡组把1只表侧表示的1星或者8星的「魔界剧团」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：自己的灵摆区域有2张「魔界剧团」卡存在的场合，把这张卡解放才能发动。从手卡以及自己的额外卡组的表侧表示怪兽之中把1只1星或者8星的「魔界剧团」灵摆怪兽特殊召唤。
function c39024589.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤与灵摆卡发动相关的处理），使其能作为灵摆怪兽正常使用。
	aux.EnablePendulumAttribute(c)
	-- ①：自己灵摆召唤成功时才能发动。从自己的额外卡组把1只表侧表示的1星或者8星的「魔界剧团」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39024589,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c39024589.thcon)
	e1:SetTarget(c39024589.thtg)
	e1:SetOperation(c39024589.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的怪兽效果1回合只能使用1次。①：自己的灵摆区域有2张「魔界剧团」卡存在的场合，把这张卡解放才能发动。从手卡以及自己的额外卡组的表侧表示怪兽之中把1只1星或者8星的「魔界剧团」灵摆怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39024589,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,39024589)
	e2:SetCondition(c39024589.spcon)
	e2:SetCost(c39024589.spcost)
	e2:SetTarget(c39024589.sptg)
	e2:SetOperation(c39024589.spop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：判断特殊召唤成功的怪兽是否为当前玩家进行的灵摆召唤。
function c39024589.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 灵摆效果发动条件：本次特殊召唤成功的怪兽中存在至少1只由自己灵摆召唤的怪兽。
function c39024589.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39024589.cfilter,1,nil,tp)
end
-- 定义可加入手牌的卡的筛选条件：表侧表示、属于「魔界剧团」、等级为1或8、是灵摆怪兽且能够加入手牌。
function c39024589.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsLevel(1,8) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 发动目标判定与处理信息登记：若满足条件则从自己额外卡组选1张符合条件的卡加入手牌，并登记本次操作的回手牌信息。
function c39024589.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查自己额外卡组是否存在至少1张满足 thfilter 的卡，作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c39024589.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 登记操作信息：本次效果为回手牌效果，预计将额外卡组的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果处理：从自己额外卡组选择1张符合条件的表侧表示灵摆怪兽加入手牌，并让对方确认该卡。
function c39024589.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己额外卡组中选择1张满足 thfilter 的卡（如果没有则不选择）。
	local g=Duel.SelectMatchingCard(tp,c39024589.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的那张卡，以便确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果发动条件：自己的灵摆区域存在至少2张「魔界剧团」卡。
function c39024589.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在至少2张卡名含有「魔界剧团」的卡（0x10ec为「魔界剧团」系列编号）。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0x10ec)
end
-- 怪兽效果发动代价：将这张卡本身解放才能发动。
function c39024589.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为发动代价（REASON_COST使该解放不受效果免疫影响）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义可特殊召唤的卡的筛选条件：手牌中的卡或额外卡组表侧表示的卡，属于「魔界剧团」、等级1或8、灵摆怪兽且能被特殊召唤；同时根据卡所在位置分别检查解放自身后是否有对应空位。
function c39024589.filter(c,e,tp,mc)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x10ec)
		and c:IsLevel(1,8) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若候选卡在手牌，则检查解放这张卡后自己场上是否还有可用的主怪兽区空格。
		and (c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp,mc)>0
			-- 若候选卡在额外卡组，则检查解放这张卡后是否存在可供额外卡组怪兽特殊召唤的可用区域（额外怪兽区或连接指向可用主怪兽区）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0)
end
-- 特殊召唤效果的目标判定与处理信息登记：若手牌或额外卡组存在符合条件的怪兽，则登记本次特殊召唤操作。
function c39024589.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查手牌和额外卡组是否存在至少1只满足 filter 的怪兽，作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c39024589.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 登记操作信息：本次效果为特殊召唤效果，预计从手牌和额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- 怪兽效果处理：从手牌或额外卡组中选择1只符合条件的「魔界剧团」灵摆怪兽特殊召唤。
function c39024589.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌和额外卡组中选择1张满足 filter 的卡（额外卡组只选表侧表示的灵摆怪兽）。
	local g=Duel.SelectMatchingCard(tp,c39024589.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
