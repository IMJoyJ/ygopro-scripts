--魔界台本「魔界の宴咜女」
-- 效果：
-- 这个卡名的①的效果1回合可以使用最多2次。
-- ①：把自己场上1只「魔界剧团」怪兽解放，以自己墓地1张「魔界台本」魔法卡为对象才能发动。那张卡在自己场上盖放。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。从卡组把「魔界剧团」灵摆怪兽任意数量特殊召唤。
function c70564929.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把自己场上1只「魔界剧团」怪兽解放，以自己墓地1张「魔界台本」魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70564929,0))  --"墓地魔法卡盖放"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(2,70564929)
	e2:SetCost(c70564929.setcost)
	e2:SetTarget(c70564929.settg)
	e2:SetOperation(c70564929.setop)
	c:RegisterEffect(e2)
	-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。从卡组把「魔界剧团」灵摆怪兽任意数量特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70564929,1))  --"卡组怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c70564929.spcon)
	e3:SetTarget(c70564929.sptg)
	e3:SetOperation(c70564929.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价：解放自己场上1只「魔界剧团」怪兽。
function c70564929.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的「魔界剧团」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x10ec) end
	-- 玩家选择自己场上1只「魔界剧团」怪兽解放。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x10ec)
	-- 解放选中的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：自己墓地的「魔界台本」魔法卡，且该卡可以盖放。
function c70564929.setfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- ①效果的发动准备：选择自己墓地1张「魔界台本」魔法卡作为对象。
function c70564929.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c70564929.setfilter(chkc) end
	-- 检查自己墓地是否存在可以盖放的「魔界台本」魔法卡。
	if chk==0 then return Duel.IsExistingTarget(c70564929.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张「魔界台本」魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,c70564929.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：有1张卡离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ①效果的效果处理：将作为对象的魔法卡在自己场上盖放。
function c70564929.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该卡在自己场上盖放。
		Duel.SSet(tp,tc)
	end
end
-- 过滤条件：额外卡组表侧表示的「魔界剧团」灵摆怪兽。
function c70564929.filter2(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- ②效果的发动条件：盖放的这张卡被对方效果破坏，且自己额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在。
function c70564929.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查自己额外卡组是否存在表侧表示的「魔界剧团」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c70564929.filter2,tp,LOCATION_EXTRA,0,1,nil)
end
-- 过滤条件：卡组中可以特殊召唤的「魔界剧团」灵摆怪兽。
function c70564929.spfilter(c,e,tp)
	return c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备：检查怪兽区域空位及卡组中是否存在可特殊召唤的怪兽。
function c70564929.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可特殊召唤的「魔界剧团」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c70564929.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息为：从卡组特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组把「魔界剧团」灵摆怪兽任意数量特殊召唤。
function c70564929.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择最多等同于空位数（且受特殊效果限制）的「魔界剧团」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c70564929.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
