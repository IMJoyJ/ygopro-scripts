--ヴァリアンツの巫女－東雲
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡是已特殊召唤的场合，自己主要阶段才能发动。从卡组把1张「群豪」魔法卡加入手卡。
-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。从卡组把「群豪之巫女-东云」以外的1只「群豪」怪兽加入手卡。
function c49131917.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，允许其进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,49131917)
	e1:SetTarget(c49131917.sptg)
	e1:SetOperation(c49131917.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡是已特殊召唤的场合，自己主要阶段才能发动。从卡组把1张「群豪」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,49131918)
	e2:SetCondition(c49131917.thcon1)
	e2:SetTarget(c49131917.thtg1)
	e2:SetOperation(c49131917.thop1)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。从卡组把「群豪之巫女-东云」以外的1只「群豪」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,49131919)
	e3:SetCondition(c49131917.thcon2)
	e3:SetTarget(c49131917.thtg2)
	e3:SetOperation(c49131917.thop2)
	c:RegisterEffect(e3)
end
-- 检查是否可以将该卡特殊召唤到指定区域
function c49131917.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置操作信息，表示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行灵摆效果的处理，将卡片特殊召唤并设置不能特殊召唤非群豪怪兽的效果
function c49131917.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将该卡特殊召唤到指定玩家的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 创建一个影响全场的永续效果，禁止玩家在回合结束前特殊召唤非群豪怪兽（除额外卡组外）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c49131917.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给指定玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义不能特殊召唤的条件：不是群豪卡组且不在额外卡组
function c49131917.splimit(e,c)
	return not c:IsSetCard(0x17d) and not c:IsLocation(LOCATION_EXTRA)
end
-- 判断该卡是否为特殊召唤状态
function c49131917.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤函数，筛选出群豪魔法卡
function c49131917.thfilter1(c)
	return c:IsSetCard(0x17d) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置操作信息，表示将要从卡组检索一张群豪魔法卡
function c49131917.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的群豪魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49131917.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索一张群豪魔法卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作
function c49131917.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的一张卡
	local g=Duel.SelectMatchingCard(tp,c49131917.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断该卡是否在怪兽区域移动且位置或控制权发生变化
function c49131917.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 过滤函数，筛选出群豪怪兽（不包括东云自身）
function c49131917.thfilter2(c)
	return not c:IsCode(49131917) and c:IsSetCard(0x17d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置操作信息，表示将要从卡组检索一张群豪怪兽
function c49131917.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的群豪怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c49131917.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索一张群豪怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作
function c49131917.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的一张卡
	local g=Duel.SelectMatchingCard(tp,c49131917.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
