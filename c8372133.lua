--スカーレッド・ファミリア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只恶魔族怪兽解放，以自己墓地1只龙族·暗属性同调怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：把墓地的这张卡除外，以自己场上1只龙族·暗属性同调怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。
function c8372133.initial_effect(c)
	-- ①：把自己场上1只恶魔族怪兽解放，以自己墓地1只龙族·暗属性同调怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8372133,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,8372133)
	e1:SetCost(c8372133.spcost)
	e1:SetTarget(c8372133.sptg)
	e1:SetOperation(c8372133.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只龙族·暗属性同调怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8372133,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,8372134)
	-- 把墓地的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c8372133.lvtg)
	e2:SetOperation(c8372133.lvop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上可解放的恶魔族怪兽，且解放后有空余怪兽区域。
function c8372133.costfilter(c,tp)
	-- 检查卡片是否为恶魔族，且解放该卡后能腾出至少1个怪兽区域，并且是自己场上的卡（若为表侧表示则可为对方场上控制权属于自己的卡）。
	return c:IsRace(RACE_FIEND) and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 过滤墓地中可以守备表示特殊召唤的龙族·暗属性同调怪兽。
function c8372133.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动代价：解放自己场上1只恶魔族怪兽。
function c8372133.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只满足条件的恶魔族怪兽可以解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c8372133.costfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择1只满足条件的恶魔族怪兽。
	local g=Duel.SelectReleaseGroup(tp,c8372133.costfilter,1,1,nil,tp)
	-- 解放选择的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果①的发动准备：选择墓地1只龙族·暗属性同调怪兽为对象。
function c8372133.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c8372133.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在可以特殊召唤的龙族·暗属性同调怪兽。
	if chk==0 then return Duel.IsExistingTarget(c8372133.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只龙族·暗属性同调怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c8372133.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将对象怪兽守备表示特殊召唤，并将其效果无效化。
function c8372133.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合效果条件，则将其守备表示特殊召唤（分步处理）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。②：把墓地的这张卡除外，以自己场上1只龙族·暗属性同调怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 完成特殊召唤的流程。
		Duel.SpecialSummonComplete()
	end
end
-- 过滤自己场上表侧表示、有等级的龙族·暗属性同调怪兽。
function c8372133.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
		and c:IsLevelAbove(1)
end
-- 效果②的发动准备：选择自己场上1只龙族·暗属性同调怪兽，并宣言1~8的等级。
function c8372133.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c8372133.lvfilter(chkc) end
	-- 检查自己场上是否存在满足条件的龙族·暗属性同调怪兽。
	if chk==0 then return Duel.IsExistingTarget(c8372133.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只龙族·暗属性同调怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c8372133.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 提示玩家选择要改变的等级。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(8372133,2))  --"请选择要改变的等级"
	-- 让玩家宣言1~8中与当前等级不同的一个等级，并将宣言的数值保存在Label中。
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- 效果②的效果处理：使作为对象的怪兽直到回合结束时变成宣言的等级。
function c8372133.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
