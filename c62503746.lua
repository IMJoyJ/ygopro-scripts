--天雷星センコウ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有地属性怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只5星以上的战士族怪兽和对方场上1只攻击表示怪兽为对象才能发动。那只自己怪兽的攻击力下降1500，那只对方怪兽破坏。
function c62503746.initial_effect(c)
	-- ①：自己场上有地属性怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62503746,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,62503746)
	e1:SetCondition(c62503746.spcon)
	e1:SetTarget(c62503746.sptg)
	e1:SetOperation(c62503746.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上1只5星以上的战士族怪兽和对方场上1只攻击表示怪兽为对象才能发动。那只自己怪兽的攻击力下降1500，那只对方怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62503746,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,62503747)
	-- 将墓地的这张卡除外作为发动效果的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c62503746.target)
	e3:SetOperation(c62503746.activate)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的地属性怪兽
function c62503746.spfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 检查是否有地属性怪兽召唤或特殊召唤成功
function c62503746.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62503746.spfilter,1,nil,tp)
end
-- 检查自身是否能特殊召唤并设置特殊召唤的操作信息
function c62503746.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理，将自身特殊召唤
function c62503746.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤自己场上表侧表示、等级5以上、战士族且攻击力在1500以上的怪兽
function c62503746.filter1(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_WARRIOR) and c:IsAttackAbove(1500)
end
-- 过滤对方场上表侧攻击表示的怪兽
function c62503746.filter2(c,check)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 选择自己场上1只符合条件的战士族怪兽和对方场上1只攻击表示怪兽作为对象
function c62503746.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在符合条件的5星以上战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c62503746.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在表侧攻击表示的怪兽
		and Duel.IsExistingTarget(c62503746.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的战士族怪兽作为对象
	local g1=Duel.SelectTarget(tp,c62503746.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只攻击表示怪兽作为对象
	local g2=Duel.SelectTarget(tp,c62503746.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 设置破坏对方怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 效果处理：使自己怪兽的攻击力下降1500，并破坏对方那只怪兽
function c62503746.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and tc:IsFaceup() and tc:IsAttackAbove(1500) then
		-- 那只自己怪兽的攻击力下降1500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and lc:IsRelateToEffect(e) and lc:IsControler(1-tp) then
			-- 破坏对方场上作为对象的怪兽
			Duel.Destroy(lc,REASON_EFFECT)
		end
	end
end
