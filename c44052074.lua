--古代の機械射出機
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有怪兽存在的场合，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，从卡组把1只「古代的机械」怪兽无视召唤条件特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，在自己场上把1只「古代的齿车衍生物」（机械族·地·1星·攻/守0）特殊召唤。
function c44052074.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，从卡组把1只「古代的机械」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44052074,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,44052074)
	e1:SetCondition(c44052074.spcon)
	e1:SetTarget(c44052074.sptg)
	e1:SetOperation(c44052074.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，在自己场上把1只「古代的齿车衍生物」（机械族·地·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44052074,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,44052074)
	-- 将这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44052074.tktg)
	e2:SetOperation(c44052074.tkop)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：自己场上没有怪兽
function c44052074.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 检索满足条件的「古代的机械」怪兽
function c44052074.spfilter(c,e,tp)
	return c:IsSetCard(0x7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果的发动条件判断：场上存在表侧表示的卡，且卡组存在满足条件的怪兽
function c44052074.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 场上存在可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 场上存在表侧表示的卡
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 卡组存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c44052074.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的卡
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置操作信息：破坏对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：破坏对象卡并特殊召唤怪兽
function c44052074.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 对象卡存在且被破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 场上没有可用的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择要特殊召唤的卡
		local g=Duel.SelectMatchingCard(tp,c44052074.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的卡无视召唤条件特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 效果的发动条件判断：场上存在表侧表示的卡，且可以特殊召唤衍生物
function c44052074.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then
		-- 获取场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 场上存在表侧表示的卡
		return Duel.IsExistingTarget(Card.IsFaceup,tp,loc,0,1,nil)
			-- 可以特殊召唤衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,44052075,0x7,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的卡
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,e:GetLabel(),0,1,1,nil)
	-- 设置操作信息：破坏对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：破坏对象卡并特殊召唤衍生物
function c44052074.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 对象卡存在且被破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 场上没有可用的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			-- 无法特殊召唤衍生物
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,44052075,0x7,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
		-- 创造衍生物
		local token=Duel.CreateToken(tp,44052075)
		-- 将衍生物特殊召唤
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
