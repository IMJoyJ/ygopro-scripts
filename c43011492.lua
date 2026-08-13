--惨禍の呪眼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「咒眼」怪兽存在的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，这个效果破坏的卡不去墓地而除外。
function c43011492.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「咒眼」怪兽存在的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，这个效果破坏的卡不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,43011492+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c43011492.condition)
	e1:SetTarget(c43011492.target)
	e1:SetOperation(c43011492.activate)
	c:RegisterEffect(e1)
end
-- 筛选「咒眼」系列且表侧表示的怪兽，用于确认自己场上是否存在满足发动条件的怪兽。
function c43011492.filter(c)
	return c:IsSetCard(0x129) and c:IsFaceup()
end
-- 发动条件判定：自己场上有表侧表示的「咒眼」怪兽存在。
function c43011492.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区域是否存在至少1只表侧表示的「咒眼」怪兽。
	return Duel.IsExistingMatchingCard(c43011492.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选可作为对象的对方场上的魔法·陷阱卡；若自己场上有「太阴之咒眼」，则同时要求该卡可以被除外。
function c43011492.desfilter(c,res)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (not res or c:IsAbleToRemove())
end
-- 筛选表侧表示的「太阴之咒眼」，用于判断是否适用除外代替去墓地的效果。
function c43011492.filter1(c)
	return c:IsCode(44133040) and c:IsFaceup()
end
-- 发动时的目标处理：确认自己场上是否有「太阴之咒眼」，选择对方场上1张符合条件的魔法·陷阱卡作为对象，并设置破坏的操作信息。
function c43011492.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己魔法与陷阱区域是否存在表侧表示的「太阴之咒眼」，结果存入res。
	local res=Duel.IsExistingMatchingCard(c43011492.filter1,tp,LOCATION_SZONE,0,1,nil)
	if chkc then return chkc:IsOnField() and c43011492.desfilter(chkc,res) and chkc:IsControler(1-tp) end
	-- 效果发动合法性检查：确认对方场上有满足条件的魔法·陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c43011492.desfilter,tp,0,LOCATION_ONFIELD,1,nil,res) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张符合条件的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c43011492.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,res)
	-- 设置本次连锁将进行1张卡的破坏的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若对象仍与效果关联，则破坏该卡；若自己场上有表侧「太阴之咒眼」，则改为不去墓地直接除外。
function c43011492.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果处理时再次确认自己魔法与陷阱区域是否存在表侧表示的「太阴之咒眼」，以决定破坏后的去向。
		if Duel.IsExistingMatchingCard(c43011492.filter1,tp,LOCATION_SZONE,0,1,nil) then
			-- 有「太阴之咒眼」存在的场合，将该卡破坏并除外（不去墓地）。
			Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
		else
			-- 没有「太阴之咒眼」存在的场合，将该卡破坏并送去墓地。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
