--カット・イン・シャーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，只让自己场上的怪兽1只成为攻击·效果的对象时，把那只怪兽解放才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从自己墓地把「切入鲨」以外的1只水属性怪兽加入手卡。
local s,id,o=GetID()
-- 初始化效果，注册该卡片的所有效果
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，只让自己场上的怪兽1只成为效果的对象时，把那只怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从自己墓地把「切入鲨」以外的1只水属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上怪兽区的怪兽
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- 判断是否满足成为效果对象时的发动条件
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.cfilter,nil,tp)==1 and eg:GetCount()==1
end
-- 过滤条件：成为对象且解放后能留出可用怪兽区域的怪兽
function s.costfilter(c,eg,tp)
	-- 检查怪兽是否在对象怪兽中，且解放后是否有可用的怪兽区域
	return eg:IsContains(c) and Duel.GetMZoneCount(tp,c)>0
end
-- 发动代价：将成为对象的1只怪兽解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放满足条件的怪兽作为发动代价
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,eg,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只满足条件的怪兽解放
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,eg,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 判断是否满足成为攻击对象时的发动条件
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否仅有自己场上的1只怪兽被对方怪兽选为攻击对象
	return eg:FilterCount(s.cfilter,nil,tp)==1 and eg:GetCount()==1 and Duel.GetAttacker():IsControler(1-tp)
end
-- 效果目标：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果处理：注册一个在回合结束阶段执行的延迟效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从自己墓地把「切入鲨」以外的1只水属性怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.cthop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段回收卡片的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：自己墓地「切入鲨」以外的水属性怪兽
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 结束阶段效果处理：从自己墓地把「切入鲨」以外的1只水属性怪兽加入手卡
function s.cthop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张满足条件的卡（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 为选中的卡片显示被选择的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
