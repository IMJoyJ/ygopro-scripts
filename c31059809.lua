--サイレンス・シーネットル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有水属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果发动的回合，自己不是水属性怪兽不能特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地最多3只水属性怪兽为对象才能发动。那些怪兽回到卡组。
function c31059809.initial_effect(c)
	-- ①：自己场上有水属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果发动的回合，自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31059809,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31059809)
	e1:SetCondition(c31059809.spcon)
	e1:SetCost(c31059809.spcost)
	e1:SetTarget(c31059809.sptg)
	e1:SetOperation(c31059809.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地最多3只水属性怪兽为对象才能发动。那些怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31059809,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,31059810)
	-- 将墓地的此卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31059809.tdtg)
	e2:SetOperation(c31059809.tdop)
	c:RegisterEffect(e2)
	-- 注册用于监测玩家是否特殊召唤了水属性以外怪兽的自定义计数器
	Duel.AddCustomActivityCounter(31059809,ACTIVITY_SPSUMMON,c31059809.counterfilter)
end
-- 计数器过滤条件：表侧表示的水属性怪兽
function c31059809.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 过滤条件：场上表侧表示的水属性怪兽
function c31059809.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果①的发动条件：自己场上存在表侧表示的水属性怪兽
function c31059809.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的水属性怪兽
	return Duel.IsExistingMatchingCard(c31059809.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动代价与限制：检查本回合特召限制并注册不能特殊召唤水属性以外怪兽的誓约效果
function c31059809.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己本回合是否没有特殊召唤过水属性以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(31059809,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：自己场上有水属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果发动的回合，自己不是水属性怪兽不能特殊召唤。②：把墓地的这张卡除外，以自己墓地最多3只水属性怪兽为对象才能发动。那些怪兽回到卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTarget(c31059809.splimit)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为发动玩家注册本回合不能特殊召唤水属性以外怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 誓约效果过滤条件：不能特殊召唤水属性以外的怪兽
function c31059809.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果①的发动准备：检查怪兽区域空位以及此卡是否可以特殊召唤
function c31059809.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：若这张卡在手牌中，则特殊召唤到自己场上
function c31059809.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己墓地的水属性怪兽且能回到卡组
function c31059809.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToDeck()
end
-- 效果②的发动准备：选择自己墓地最多3只水属性怪兽作为对象，并设置送回卡组的操作信息
function c31059809.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31059809.tdfilter(chkc) end
	-- 检查自己墓地是否存在可以回到卡组的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c31059809.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家提示选择需要送回卡组的对象卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1到3只水属性怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c31059809.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置操作信息：将选中的对象怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的效果处理：将符合条件的对象怪兽送回卡组并洗牌
function c31059809.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与此效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将选中的怪兽送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
