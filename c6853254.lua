--復活の福音
-- 效果：
-- ①：以自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己场上的龙族怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c6853254.initial_effect(c)
	-- ①：以自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c6853254.target)
	e1:SetOperation(c6853254.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的龙族怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c6853254.reptg)
	e2:SetValue(c6853254.repval)
	e2:SetOperation(c6853254.repop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以特殊召唤的7·8星龙族怪兽
function c6853254.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备，确认怪兽区域空位、是否存在合法目标并选择对象
function c6853254.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c6853254.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的7·8星龙族怪兽
		and Duel.IsExistingTarget(c6853254.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的龙族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c6853254.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该连锁包含特殊召唤该目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理，将作为对象的怪兽特殊召唤
function c6853254.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上因战斗或效果被破坏的表侧表示龙族怪兽
function c6853254.repfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的判定，检查此卡是否可以除外以及是否有龙族怪兽将被破坏，并询问玩家是否发动
function c6853254.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c6853254.repfilter,1,nil,tp) end
	-- 询问玩家是否使用此卡代替破坏
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏效果所适用的对象
function c6853254.repval(e,c)
	return c6853254.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏的操作，将墓地的此卡除外
function c6853254.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
