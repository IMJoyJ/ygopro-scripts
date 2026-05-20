--アルギロスの落胤
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：场上有2星·2阶·连接2的怪兽的其中任意种存在的场合，这张卡可以从手卡往自己或者对方场上特殊召唤。
-- ②：双方不能把有这张卡位于所连接区的连接怪兽的效果发动。
-- ③：对方回合，以场上1只超量怪兽为对象才能发动。那只怪兽最多2个超量素材取除。
function c82090807.initial_effect(c)
	-- ①：场上有2星·2阶·连接2的怪兽的其中任意种存在的场合，这张卡可以从手卡往自己或者对方场上特殊召唤。（往自己场上特殊召唤）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82090807,0))  --"往自己场上特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,82090807+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c82090807.sprcon1)
	c:RegisterEffect(e1)
	-- ①：场上有2星·2阶·连接2的怪兽的其中任意种存在的场合，这张卡可以从手卡往自己或者对方场上特殊召唤。（往对方场上特殊召唤）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82090807,1))  --"往对方场上特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP,1)
	e2:SetCountLimit(1,82090807+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c82090807.sprcon2)
	c:RegisterEffect(e2)
	-- ②：双方不能把有这张卡位于所连接区的连接怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c82090807.actfilter)
	c:RegisterEffect(e3)
	-- ③：对方回合，以场上1只超量怪兽为对象才能发动。那只怪兽最多2个超量素材取除。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82090807,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,82090808)
	e4:SetCondition(c82090807.dhcon)
	e4:SetTarget(c82090807.dhtg)
	e4:SetOperation(c82090807.dhop)
	c:RegisterEffect(e4)
end
-- 过滤场上表侧表示的2星、2阶或连接2的怪兽
function c82090807.twofilter(c)
	return c:IsFaceup() and (c:IsLevel(2) or c:IsLink(2) or c:IsRank(2))
end
-- 往自己场上特殊召唤的条件：自己场上有空位且场上存在2星、2阶或连接2的怪兽
function c82090807.sprcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在表侧表示的2星、2阶或连接2的怪兽
		and Duel.IsExistingMatchingCard(c82090807.twofilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 往对方场上特殊召唤的条件：对方场上有空位且场上存在2星、2阶或连接2的怪兽
function c82090807.sprcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否有可用的怪兽区域
	return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查场上是否存在表侧表示的2星、2阶或连接2的怪兽
		and Duel.IsExistingMatchingCard(c82090807.twofilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤指向这张卡（即这张卡位于其所连接区）的连接怪兽
function c82090807.actfilter(e,c)
	local g=c:GetLinkedGroup()
	return c:IsType(TYPE_LINK) and g:IsContains(e:GetHandler())
end
-- 效果③的发动条件：对方回合
function c82090807.dhcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤场上表侧表示且拥有超量素材的超量怪兽
function c82090807.xfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
-- 效果③的靶向/目标选择：检查并选择场上1只拥有超量素材的超量怪兽作为对象
function c82090807.dhtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c82090807.xfilter(chkc) end
	-- 检查场上是否存在至少1只可以作为对象的、拥有超量素材的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c82090807.xfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择效果对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只拥有超量素材的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c82090807.xfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果③的执行：取除作为对象的超量怪兽的1到2个超量素材
function c82090807.dhop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:GetOverlayCount()>0 then
		tc:RemoveOverlayCard(tp,1,2,REASON_EFFECT)
	end
end
