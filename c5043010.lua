--ファイアウォール・ドラゴン
-- 效果：
-- 怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：只在这张卡在场上表侧表示存在才有1次，自己·对方回合，以最多有这张卡所互相连接区的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
-- ②：这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。从手卡把1只电子界族怪兽特殊召唤。
function c5043010.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求至少2个连接素材
	aux.AddLinkProcedure(c,nil,2)
	c:EnableReviveLimit()
	-- ①：只在这张卡在场上表侧表示存在才有1次，自己·对方回合，以最多有这张卡所互相连接区的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5043010,0))  --"回到持有者手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5043010)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c5043010.thtg)
	e1:SetOperation(c5043010.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。从手卡把1只电子界族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c5043010.regcon)
	e2:SetOperation(c5043010.regop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c5043010.regcon2)
	c:RegisterEffect(e3)
	-- 只在这张卡在场上表侧表示存在才有1次，自己·对方回合，以最多有这张卡所互相连接区的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5043010,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_CUSTOM+5043010)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,5043011)
	e4:SetTarget(c5043010.sptg)
	e4:SetOperation(c5043010.spop)
	c:RegisterEffect(e4)
end
-- 定义返回手牌效果的过滤函数，筛选可以送回手牌的怪兽
function c5043010.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置①效果的目标选择函数，检查是否满足条件并选择目标怪兽
function c5043010.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ct=c:GetMutualLinkedGroupCount()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c5043010.thfilter(chkc) end
	-- 判断①效果是否可以发动，检查连接区怪兽数量和是否存在可选目标
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c5043010.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 根据过滤条件选择目标怪兽
	local g=Duel.SelectTarget(tp,c5043010.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,ct,nil)
	-- 设置效果处理信息，告知连锁将要执行的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(5043010,2))  --"已发动过效果"
end
-- ①效果的处理函数，将目标怪兽数量送回手牌
function c5043010.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡片组，并筛选与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的卡片以效果原因送回手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
-- 判断怪兽是否从场上被破坏并满足连接区条件的过滤函数
function c5043010.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- ②效果的触发条件，检查是否有连接区怪兽被战斗破坏或送去墓地
function c5043010.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5043010.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 用于排除战斗破坏情况的过滤函数
function c5043010.cfilter2(c,tp,zone)
	return not c:IsReason(REASON_BATTLE) and c5043010.cfilter(c,tp,zone)
end
-- ②效果的触发条件，检查是否有连接区怪兽被送去墓地（非战斗破坏）
function c5043010.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5043010.cfilter2,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- ②效果的处理函数，触发自定义事件以激活特殊召唤效果
function c5043010.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发一个单体时点，用于激活②效果的特殊召唤
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+5043010,e,0,tp,0,0)
end
-- 定义特殊召唤效果的过滤函数，筛选电子界族且可特殊召唤的怪兽
function c5043010.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置②效果的目标选择函数，检查是否满足条件并选择目标怪兽
function c5043010.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断②效果是否可以发动，检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断②效果是否可以发动，检查手牌中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c5043010.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置②效果处理信息，告知连锁将要执行的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理函数，从手牌特殊召唤一只电子界族怪兽
function c5043010.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有足够的召唤位置进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 根据过滤条件选择目标怪兽
	local g=Duel.SelectMatchingCard(tp,c5043010.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将符合条件的卡片以效果原因特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
