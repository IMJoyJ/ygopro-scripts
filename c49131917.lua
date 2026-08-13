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
	-- 为这张卡启用灵摆怪兽属性，使其获得灵摆召唤及灵摆卡发动相关的内置功能。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,49131917)
	e1:SetTarget(c49131917.sptg)
	e1:SetOperation(c49131917.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：这张卡是已特殊召唤的场合，自己主要阶段才能发动。从卡组把1张「群豪」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,49131918)
	e2:SetCondition(c49131917.thcon1)
	e2:SetTarget(c49131917.thtg1)
	e2:SetOperation(c49131917.thop1)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。从卡组把「群豪之巫女-东云」以外的1只「群豪」怪兽加入手卡。
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
-- 灵摆效果①发动时的目标合法性检测：获取自身在灵摆区的格子序号并换算成正对面主要怪兽区域的zone，若为发动时检查自身能否表侧表示特殊召唤到该区域。
function c49131917.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 为本次特殊召唤设置操作信息，将这张卡登记为预定特殊召唤的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理灵摆效果①：将这张卡特殊召唤到正对面的自己的主要怪兽区域，并给当前玩家附加直到回合结束时不能特殊召唤非「群豪」怪兽（除额外卡组外）的自肃效果。
function c49131917.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到zone所指定的正对面的主要怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。这个卡名的①②的怪兽效果1回合各能使用1次。①：这张卡是已特殊召唤的场合，自己主要阶段才能发动。从卡组把1张「群豪」魔法卡加入手卡。②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。从卡组把「群豪之巫女-东云」以外的1只「群豪」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c49131917.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述特殊召唤自肃效果注册给当前玩家，使其持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤条件：只有既不是「群豪」系列且不在额外卡组的怪兽才被禁止特殊召唤，因此允许从额外卡组进行特殊召唤。
function c49131917.splimit(e,c)
	return not c:IsSetCard(0x17d) and not c:IsLocation(LOCATION_EXTRA)
end
-- 怪兽效果①的发动条件：这张卡是以特殊召唤方式出场的场合。
function c49131917.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 怪兽效果①的检索过滤：从卡组选择1张「群豪」魔法卡且该卡能够加入手牌。
function c49131917.thfilter1(c)
	return c:IsSetCard(0x17d) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 怪兽效果①的发动时点处理：确认卡组存在符合条件的「群豪」魔法卡，并设置从卡组加入手牌的操作信息。
function c49131917.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：卡组中存在至少1张满足thfilter1的「群豪」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49131917.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索加入手牌的操作信息：不取对象，预定从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理怪兽效果①：从卡组选1张「群豪」魔法卡加入手牌，并让对方确认。
function c49131917.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter1的「群豪」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c49131917.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果②的发动条件：这张卡从怪兽区域的原来位置移动到了另一个怪兽区域（格子变化或控制权变化），符合“向其他的怪兽区域移动的场合”。
function c49131917.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 怪兽效果②的检索过滤：从卡组选择1张不是「群豪之巫女-东云」的「群豪」怪兽且能够加入手牌。
function c49131917.thfilter2(c)
	return not c:IsCode(49131917) and c:IsSetCard(0x17d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 怪兽效果②的发动时点处理：确认卡组存在符合条件的「群豪」怪兽，并设置从卡组加入手牌的操作信息。
function c49131917.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：卡组中存在至少1张满足thfilter2的「群豪」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c49131917.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索加入手牌的操作信息：不取对象，预定从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理怪兽效果②：从卡组选1张符合条件的「群豪」怪兽加入手牌，并让对方确认。
function c49131917.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter2的「群豪」怪兽（本卡名以外）。
	local g=Duel.SelectMatchingCard(tp,c49131917.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
