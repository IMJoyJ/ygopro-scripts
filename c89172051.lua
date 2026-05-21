--ドラグニティ－レガトゥス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有「龙骑兵团」怪兽或「龙之溪谷」存在的场合才能发动。这张卡特殊召唤。
-- ②：自己的魔法与陷阱区域有「龙骑兵团」怪兽卡存在的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c89172051.initial_effect(c)
	-- 注册卡片记载了「龙之溪谷」的卡片密码
	aux.AddCodeList(c,62265044)
	-- ①：这张卡在手卡存在，自己场上有「龙骑兵团」怪兽或「龙之溪谷」存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89172051,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,89172051)
	e1:SetCondition(c89172051.spcon)
	e1:SetTarget(c89172051.sptg)
	e1:SetOperation(c89172051.spop)
	c:RegisterEffect(e1)
	-- ②：自己的魔法与陷阱区域有「龙骑兵团」怪兽卡存在的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89172051,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,89172052)
	e2:SetCondition(c89172051.descon)
	e2:SetTarget(c89172051.destg)
	e2:SetOperation(c89172051.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「龙骑兵团」怪兽
function c89172051.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- 特殊召唤效果的条件：自己场上有「龙之溪谷」或表侧表示的「龙骑兵团」怪兽存在
function c89172051.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「龙之溪谷」或自己场上是否存在表侧表示的「龙骑兵团」怪兽
	return Duel.IsEnvironment(62265044,tp) or Duel.IsExistingMatchingCard(c89172051.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c89172051.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤
function c89172051.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：魔法与陷阱区域表侧表示的、原本是怪兽的「龙骑兵团」卡片
function c89172051.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 破坏效果的条件：自己的魔法与陷阱区域有「龙骑兵团」怪兽卡存在
function c89172051.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的魔法与陷阱区域是否存在「龙骑兵团」怪兽卡
	return Duel.IsExistingMatchingCard(c89172051.cfilter2,tp,LOCATION_SZONE,0,1,nil)
end
-- 过滤条件：魔法或陷阱卡
function c89172051.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动准备：选择场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息
function c89172051.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c89172051.desfilter(chkc) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c89172051.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c89172051.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏的操作信息，将选择的卡作为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理：破坏作为对象的卡
function c89172051.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
