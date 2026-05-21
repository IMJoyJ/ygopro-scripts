--大霊峰相剣門
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「相剑」怪兽为对象才能发动（自己场上有同调怪兽存在的场合，也能作为代替以1只幻龙族怪兽为对象）。那只怪兽特殊召唤。
-- ②：这张卡被除外的场合，以自己场上1只「相剑」怪兽或者幻龙族怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或者下降1星。
function c93850690.initial_effect(c)
	-- ①：以自己墓地1只「相剑」怪兽为对象才能发动（自己场上有同调怪兽存在的场合，也能作为代替以1只幻龙族怪兽为对象）。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93850690,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,93850690)
	e1:SetTarget(c93850690.target)
	e1:SetOperation(c93850690.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己场上1只「相剑」怪兽或者幻龙族怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或者下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93850690,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,93850691)
	e2:SetTarget(c93850690.lvtg)
	e2:SetOperation(c93850690.lvop)
	c:RegisterEffect(e2)
end
-- 过滤墓地中可以特殊召唤的「相剑」怪兽，或者在满足条件时过滤幻龙族怪兽
function c93850690.spfilter(c,e,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((check and c:IsRace(RACE_WYRM)) or c:IsSetCard(0x16b))
end
-- 过滤自己场上表侧表示的同调怪兽
function c93850690.checkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 效果①的发动准备，检查场上是否有同调怪兽，并选择墓地中符合条件的怪兽作为对象
function c93850690.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在表侧表示的同调怪兽
	local check=Duel.IsExistingMatchingCard(c93850690.checkfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93850690.spfilter(chkc,e,tp,check) end
	-- 检查自己场上是否有可以特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为特殊召唤对象的怪兽
		and Duel.IsExistingTarget(c93850690.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,check) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93850690.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理，特殊召唤作为对象的怪兽
function c93850690.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示、等级大于0的「相剑」怪兽或幻龙族怪兽
function c93850690.lvfilter(c)
	return (c:IsSetCard(0x16b) or (c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WYRM))) and c:IsFaceup() and c:GetLevel()>0
end
-- 效果②的发动准备，选择自己场上1只「相剑」怪兽或幻龙族怪兽作为对象
function c93850690.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c93850690.lvfilter(chkc) end
	-- 检查自己场上是否存在可以作为等级变化对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c93850690.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c93850690.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理，让作为对象的怪兽等级直到回合结束时上升或下降1星
function c93850690.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			-- 当目标怪兽等级为1时，让玩家选择“等级上升”选项
			sel=Duel.SelectOption(tp,aux.Stringid(93850690,2))  --"等级上升"
		else
			-- 让玩家选择“等级上升”或“等级下降”
			sel=Duel.SelectOption(tp,aux.Stringid(93850690,2),aux.Stringid(93850690,3))  --"等级上升/等级下降"
		end
		if sel==1 then
			lvl=-1
		end
		-- 那只怪兽的等级直到回合结束时上升或者下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
