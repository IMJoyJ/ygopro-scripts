--百鬼羅刹の大饕獣
-- 效果：
-- 6星怪兽×2只以上
-- 这个卡名的③的效果在决斗中只能使用1次。
-- ①：自己·对方回合1次，以场上1张魔法·陷阱卡为对象才能发动。场上2个超量素材取除，把作为对象的卡作为这张卡的超量素材。
-- ②：自己场上的怪兽被效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
-- ③：这张卡在墓地存在的场合才能发动。这张卡特殊召唤。那之后，可以把自己墓地1只「哥布林」怪兽作为这张卡的超量素材。
function c71100270.initial_effect(c)
	-- 设置XYZ召唤手续：等级6怪兽2只以上（最多7只）
	aux.AddXyzProcedure(c,nil,6,2,nil,nil,7)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，以场上1张魔法·陷阱卡为对象才能发动。场上2个超量素材取除，把作为对象的卡作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71100270,0))  --"场上卡作为超量素材"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetTarget(c71100270.xmtg)
	e1:SetOperation(c71100270.xmop)
	c:RegisterEffect(e1)
	-- ②：自己场上的怪兽被效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c71100270.reptg)
	e2:SetValue(c71100270.repval)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合才能发动。这张卡特殊召唤。那之后，可以把自己墓地1只「哥布林」怪兽作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,71100270+EFFECT_COUNT_CODE_DUEL)
	e3:SetTarget(c71100270.sptg)
	e3:SetOperation(c71100270.spop)
	c:RegisterEffect(e3)
end
-- 过滤场上可以作为超量素材的魔法·陷阱卡
function c71100270.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsCanOverlay()
end
-- 效果①的发动准备与对象选择
function c71100270.xmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and c71100270.filter(chkc) end
	-- 检查场上（双方场上）是否存在至少2个可以被效果取除的超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,2,REASON_EFFECT)
		-- 检查场上是否存在可以作为对象的魔法·陷阱卡
		and Duel.IsExistingTarget(c71100270.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要作为超量素材的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 玩家选择场上1张魔法·陷阱卡作为效果对象
	Duel.SelectTarget(tp,c71100270.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 效果①的处理：取除场上2个超量素材，将对象卡作为这张卡的超量素材
function c71100270.xmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	-- 成功从场上（双方场上）取除2个超量素材
	if Duel.RemoveOverlayCard(tp,1,1,2,2,REASON_EFFECT)~=0
		and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将作为对象的卡片原本拥有的超量素材送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		tc:CancelToGrave()
		-- 将对象卡作为这张卡的超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 过滤自己场上因效果破坏的怪兽
function c71100270.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 效果②的代替破坏判定：检查是否有自己场上的怪兽被效果破坏，且这张卡有超量素材可取除
function c71100270.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c71100270.repfilter,1,nil,tp)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否使用代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	end
	return false
end
-- 确定被代替破坏的卡片是否符合过滤条件
function c71100270.repval(e,c)
	return c71100270.repfilter(c,e:GetHandlerPlayer())
end
-- 效果③的发动准备：检查怪兽区域是否有空位，以及这张卡是否能特殊召唤
function c71100270.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤自己墓地中可以作为超量素材的「哥布林」怪兽
function c71100270.mfilter(c)
	return c:IsSetCard(0xac) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果③的处理：特殊召唤自身，之后可选择将墓地1只「哥布林」怪兽作为超量素材
function c71100270.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取自己墓地中不受「王家之谷」影响的「哥布林」怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c71100270.mfilter),tp,LOCATION_GRAVE,0,nil)
		-- 若墓地存在符合条件的怪兽，询问玩家是否将其作为超量素材
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(71100270,1)) then  --"是否把墓地1只「哥布林」怪兽作为这张卡的超量素材？"
			-- 中断当前效果处理，使后续的叠放素材处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要作为超量素材的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local mg=g:Select(tp,1,1,nil)
			-- 将选择的「哥布林」怪兽作为这张卡的超量素材
			Duel.Overlay(c,mg)
		end
	end
end
