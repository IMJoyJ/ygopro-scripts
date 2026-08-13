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
-- 过滤函数：判定自己墓地的怪兽是否为机械族「电子」融合怪兽，且满足能回额外卡组或场上有空位可无视召唤条件特殊召唤。
function c32768230.spfilter(c,e,tp)
	-- 取得自己场上主要怪兽区的可用空格数量，用于判断能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsSetCard(0x93) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION)
		and (c:IsAbleToExtra() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)))
end
-- ①效果的发动条件与对象选择：从自己墓地选择1只符合条件的机械族「电子」融合怪兽为对象（取对象效果）。
function c32768230.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32768230.spfilter(chkc,e,tp) end
	-- 发动合法性检查：自己墓地是否存在至少1只符合条件的机械族「电子」融合怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c32768230.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发出选择对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地的符合条件的机械族「电子」融合怪兽中选择1张作为效果对象。
	local g=Duel.SelectTarget(tp,c32768230.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
-- ①效果处理：将作为对象的怪兽根据玩家选择返回额外卡组或无视召唤条件特殊召唤；若对象受王家长眠之谷影响则效果无效。
function c32768230.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 取得自己场上可用怪兽区空格数，用于判断能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if tc:IsRelateToEffect(e) then
		-- 若对象怪兽处于王家长眠之谷的无效影响下，则直接结束本次效果处理。
		if aux.NecroValleyNegateCheck(tc) then return end
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
			-- 决定处理分支：若对象不能返回额外卡组，或玩家选择“特殊召唤”（选项返回1），则执行特殊召唤；否则执行返回额外卡组。
			and (not tc:IsAbleToExtra() or Duel.SelectOption(tp,aux.Stringid(32768230,0),1152)==1) then  --"回到额外卡组"
			-- 将对象怪兽以表侧表示、无视召唤条件特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		else
			-- 将对象怪兽返回额外卡组（额外卡组怪兽通过送入卡组的方式回到额外卡组）。
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 代替破坏的判定条件：自己场上的表侧表示机械族「电子」融合怪兽，正被战斗或效果破坏，且不是由代替破坏引起的破坏。
function c32768230.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x93) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判定是否满足代替破坏的发动条件：墓地的这张卡可除外，且本应被破坏的怪兽中存在符合条件的机械族「电子」融合怪兽；然后询问玩家是否发动。
function c32768230.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c32768230.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果，并返回是否选择的布尔值。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 用于代替破坏判定的值函数：当怪兽被破坏时，判断该怪兽是否满足被代替破坏的筛选条件。
function c32768230.repval(e,c)
	return c32768230.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的实际处理：将墓地中的这张卡除外，从而代替怪兽的破坏。
function c32768230.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行除外操作：将墓地的这张卡表侧表示除外，完成代替破坏的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
