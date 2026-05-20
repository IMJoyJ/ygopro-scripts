--殲滅のタキオン・スパイラル
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己场上有「银河」超量怪兽存在的场合才能发动。效果被无效化的对方场上的表侧表示卡全部破坏。
-- ●以「歼灭之时空螺旋」以外的自己墓地1张「时空」卡为对象才能发动。那张卡加入手卡。
-- ●以自己墓地1只龙族「No.」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含三个可选择发动的效果（同名卡每个效果1回合各能选择1次）
function s.initial_effect(c)
	-- ●自己场上有「银河」超量怪兽存在的场合才能发动。效果被无效化的对方场上的表侧表示卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ●以「歼灭之时空螺旋」以外的自己墓地1张「时空」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ●以自己墓地1只龙族「No.」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示的「银河」超量怪兽
function s.descfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7b) and c:IsType(TYPE_XYZ)
end
-- 效果1的发动条件：自己场上存在「银河」超量怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件的「银河」超量怪兽
	return Duel.IsExistingMatchingCard(s.descfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：对方场上表侧表示且效果被无效化的卡
function s.desfilter(c)
	return c:IsFaceup() and c:IsDisabled()
end
-- 效果1的发动准备（检查对方场上是否有符合条件的卡、设置破坏操作信息、向对方提示选择的效果）
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张效果被无效化的表侧表示卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有效果被无效化的表侧表示卡
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏操作信息，包含要破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 向对方玩家提示当前选择发动的是破坏效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果1的处理：获取并破坏对方场上所有效果被无效化的表侧表示卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有效果被无效化的表侧表示卡
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏这些卡
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 过滤条件：自己墓地「歼灭之时空螺旋」以外的「时空」卡，且能加入手卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1b4) and c:IsAbleToHand()
end
-- 效果2的发动准备（检查墓地目标、选择回收对象、设置加入手卡操作信息）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张符合条件的「时空」卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示当前选择发动的是回收效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的「时空」卡作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置加入手卡操作信息，包含目标卡片和数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果2的处理：将作为对象的卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果将目标卡加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：自己墓地的龙族「No.」怪兽，且能以守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果3的发动准备（检查怪兽区域空格、墓地目标、选择特殊召唤对象、设置特殊召唤操作信息）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只符合条件的龙族「No.」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示当前选择发动的是特殊召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的龙族「No.」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作信息，包含目标怪兽和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果3的处理：将作为对象的怪兽守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
