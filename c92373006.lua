--スレイブタイガー
-- 效果：
-- ①：自己场上有「剑斗兽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放，以自己场上1只「剑斗兽」怪兽为对象才能发动。那只自己的「剑斗兽」怪兽回到持有者卡组，从卡组把1只「剑斗兽」怪兽特殊召唤。这个效果特殊召唤的怪兽变成当作用「剑斗兽」怪兽的效果特殊召唤使用。
function c92373006.initial_effect(c)
	-- ①：自己场上有「剑斗兽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92373006,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c92373006.sprcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以自己场上1只「剑斗兽」怪兽为对象才能发动。那只自己的「剑斗兽」怪兽回到持有者卡组，从卡组把1只「剑斗兽」怪兽特殊召唤。这个效果特殊召唤的怪兽变成当作用「剑斗兽」怪兽的效果特殊召唤使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92373006,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c92373006.spcost)
	e2:SetTarget(c92373006.sptg)
	e2:SetOperation(c92373006.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「剑斗兽」怪兽
function c92373006.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 特殊召唤规则的条件：自身控制者场上有可用的怪兽区域，且存在表侧表示的「剑斗兽」怪兽
function c92373006.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自身控制者的主要怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c92373006.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动代价：解放自身
function c92373006.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 将自身作为发动代价解放并送去墓地
	Duel.Release(c,REASON_COST)
end
-- 过滤条件：自己场上表侧表示且能回到卡组的「剑斗兽」怪兽
function c92373006.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019) and c:IsAbleToDeck()
end
-- 过滤条件：卡组中可以被「剑斗兽」怪兽效果特殊召唤的「剑斗兽」怪兽
function c92373006.spfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_GLADIATOR,tp,false,false)
end
-- 效果发动准备：检查怪兽区域空位、是否存在可作为对象的「剑斗兽」怪兽以及卡组中是否有可特殊召唤的「剑斗兽」怪兽，并选择对象
function c92373006.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c92373006.tgfilter(chkc) end
	-- 检查怪兽区域空位（考虑自身解放和对象怪兽回到卡组释放的格子）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		-- 检查自己场上是否存在可作为对象的「剑斗兽」怪兽
		and Duel.IsExistingTarget(c92373006.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己卡组中是否存在可特殊召唤的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c92373006.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上1只表侧表示的「剑斗兽」怪兽作为效果对象
	Duel.SelectTarget(tp,c92373006.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理：将作为对象的怪兽返回卡组，并从卡组特殊召唤1只「剑斗兽」怪兽，该怪兽视为用「剑斗兽」怪兽的效果特殊召唤
function c92373006.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local rc=Duel.GetFirstTarget()
	if not rc or rc:IsFacedown() or not rc:IsRelateToEffect(e) then return end
	-- 将作为对象的怪兽返回持有者卡组并洗牌
	local rt=Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if rt==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足特殊召唤条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c92373006.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤，并带有「剑斗兽」效果召唤的标记（SUMMON_VALUE_GLADIATOR）
		Duel.SpecialSummon(tc,SUMMON_VALUE_GLADIATOR,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
