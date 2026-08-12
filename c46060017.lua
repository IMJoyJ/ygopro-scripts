--十二獣の会局
-- 效果：
-- 「十二兽的会局」的①的效果1回合只能使用1次。
-- ①：以自己场上1张表侧表示的卡为对象才能把这个效果发动。那张卡破坏，从卡组把1只「十二兽」怪兽特殊召唤。
-- ②：这张卡被效果破坏送去墓地的场合，以自己场上1只「十二兽」超量怪兽为对象才能发动。把墓地的这张卡在那只超量怪兽下面重叠作为超量素材。
function c46060017.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1张表侧表示的卡为对象才能把这个效果发动。那张卡破坏，从卡组把1只「十二兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46060017,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,46060017)
	e2:SetTarget(c46060017.sptg)
	e2:SetOperation(c46060017.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果破坏送去墓地的场合，以自己场上1只「十二兽」超量怪兽为对象才能发动。把墓地的这张卡在那只超量怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46060017,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c46060017.matcon)
	e3:SetTarget(c46060017.mattg)
	e3:SetOperation(c46060017.matop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为「十二兽」怪兽且可以特殊召唤
function c46060017.spfilter(c,e,tp)
	return c:IsSetCard(0xf1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断与目标选择函数，检查场上是否存在表侧表示的卡并确认卡组中是否有「十二兽」怪兽可特殊召唤
function c46060017.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then
		-- 获取玩家在主要怪兽区可用的空格数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 检查场上是否存在满足条件的表侧表示的卡
		return Duel.IsExistingTarget(Card.IsFaceup,tp,loc,0,1,nil)
			-- 检查卡组中是否存在满足条件的「十二兽」怪兽
			and Duel.IsExistingMatchingCard(c46060017.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标卡作为被破坏的对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,e:GetLabel(),0,1,1,nil)
	-- 设置操作信息，标记将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，标记将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行破坏和特殊召唤的操作
function c46060017.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上并进行破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查是否有足够的怪兽区空间用于特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择一只「十二兽」怪兽作为特殊召唤对象
		local g=Duel.SelectMatchingCard(tp,c46060017.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「十二兽」怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 判断该卡是否因效果破坏而进入墓地
function c46060017.matcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),0x41)==0x41
end
-- 过滤函数，用于判断是否为「十二兽」超量怪兽
function c46060017.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and c:IsType(TYPE_XYZ)
end
-- 效果处理时的条件判断与目标选择函数，检查场上是否存在满足条件的「十二兽」超量怪兽
function c46060017.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46060017.matfilter(chkc) end
	-- 检查场上是否存在满足条件的「十二兽」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c46060017.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标卡作为超量素材的目标
	Duel.SelectTarget(tp,c46060017.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，标记将要叠放的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行将卡叠放到目标超量怪兽上的操作
function c46060017.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsCanOverlay() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 将卡叠放到目标超量怪兽上
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
