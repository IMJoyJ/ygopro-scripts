--エターナル・サイバー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只机械族「电子」融合怪兽为对象才能发动。那只怪兽回到额外卡组或无视召唤条件特殊召唤。
-- ②：自己场上的机械族「电子」融合怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c32768230.initial_effect(c)
	-- ①：以自己墓地1只机械族「电子」融合怪兽为对象才能发动。那只怪兽回到额外卡组或无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,32768230)
	e1:SetTarget(c32768230.target)
	e1:SetOperation(c32768230.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的机械族「电子」融合怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,32768231)
	e2:SetTarget(c32768230.reptg)
	e2:SetValue(c32768230.repval)
	e2:SetOperation(c32768230.repop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的墓地机械族电子融合怪兽，判断其是否能回到额外卡组或能特殊召唤
function c32768230.spfilter(c,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsSetCard(0x93) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION)
		and (c:IsAbleToExtra() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)))
end
-- 效果处理时判断目标是否满足条件并选择目标
function c32768230.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32768230.spfilter(chkc,e,tp) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c32768230.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c32768230.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
-- 处理效果发动时的特殊召唤或送回额外卡组
function c32768230.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if tc:IsRelateToEffect(e) then
		-- 检查目标怪兽是否被王家长眠之谷保护
		if aux.NecroValleyNegateCheck(tc) then return end
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
			-- 判断是否选择将怪兽送回额外卡组
			and (not tc:IsAbleToExtra() or Duel.SelectOption(tp,aux.Stringid(32768230,0),1152)==1) then  --"回到额外卡组"
			-- 将目标怪兽无视召唤条件特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		else
			-- 将目标怪兽送回卡组
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 判断是否为场上被战斗或效果破坏的机械族电子融合怪兽
function c32768230.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x93) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否可以发动代替破坏效果
function c32768230.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c32768230.repfilter,1,nil,tp) end
	-- 提示玩家选择是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回代替破坏效果的判断条件
function c32768230.repval(e,c)
	return c32768230.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果，将卡片除外
function c32768230.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身从墓地除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
