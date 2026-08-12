--彼岸の悪鬼 ハックルスパー
-- 效果：
-- 「彼岸的恶鬼 卡尔卡布里纳」的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的场合，以场上盖放的1张魔法·陷阱卡为对象才能发动。盖放的那张卡回到持有者手卡。
function c73213494.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c73213494.sdcon)
	c:RegisterEffect(e1)
	-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73213494,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,73213494)
	e2:SetCondition(c73213494.sscon)
	e2:SetTarget(c73213494.sstg)
	e2:SetOperation(c73213494.ssop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以场上盖放的1张魔法·陷阱卡为对象才能发动。盖放的那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73213494,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,73213494)
	e3:SetTarget(c73213494.thtg)
	e3:SetOperation(c73213494.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：里侧表示或非「彼岸」怪兽
function c73213494.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 自毁效果的判定条件：自己场上存在里侧表示怪兽或非「彼岸」怪兽
function c73213494.sdcon(e)
	-- 检查自己场上是否存在至少1张里侧表示或非「彼岸」的怪兽
	return Duel.IsExistingMatchingCard(c73213494.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：魔法或陷阱卡
function c73213494.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤效果的发动条件：自己场上没有魔法·陷阱卡存在
function c73213494.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(c73213494.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果的发动准备（检查怪兽区域空位及自身是否能特殊召唤，并设置操作信息）
function c73213494.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段（chk==0）检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤到场上
function c73213494.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：盖放（里侧表示）且能回到手牌的卡
function c73213494.thfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 回到手牌效果的发动准备（选择场上盖放的1张魔法·陷阱卡作为对象，并设置操作信息）
function c73213494.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c73213494.thfilter(chkc) end
	-- 在效果发动阶段（chk==0）检查双方魔陷区是否存在至少1张盖放且能回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(c73213494.thfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择双方魔陷区1张盖放的卡作为效果的对象
	local g=Duel.SelectTarget(tp,c73213494.thfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回到手牌效果的处理：将作为对象的盖放卡送回持有者手牌
function c73213494.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 通过效果将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
