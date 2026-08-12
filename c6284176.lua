--六花聖カンザシ
-- 效果：
-- 6星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：怪兽被解放的场合，把这张卡1个超量素材取除，以自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽效果无效化，变成植物族。
-- ②：自己场上的植物族怪兽被效果破坏的场合，可以作为代替把自己的手卡·场上1只植物族怪兽解放。
function c6284176.initial_effect(c)
	-- 添加XYZ召唤手续：6星怪兽×2
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：怪兽被解放的场合，把这张卡1个超量素材取除，以自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽效果无效化，变成植物族。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6284176,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,6284176)
	e1:SetCondition(c6284176.spcon)
	e1:SetCost(c6284176.spcost)
	e1:SetTarget(c6284176.sptg)
	e1:SetOperation(c6284176.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的植物族怪兽被效果破坏的场合，可以作为代替把自己的手卡·场上1只植物族怪兽解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,6284177)
	e2:SetTarget(c6284176.reptg)
	e2:SetValue(c6284176.repval)
	e2:SetOperation(c6284176.repop)
	c:RegisterEffect(e2)
end
-- 过滤条件：被解放的怪兽（必须是原本在怪兽区域的怪兽，或者是从非魔法陷阱区解放的怪兽卡）
function c6284176.cfilter(c)
	return (c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_SZONE)) or c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果①的发动条件：有怪兽被解放，且被解放的怪兽不包含这张卡自身
function c6284176.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c6284176.cfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 效果①的代价值：把这张卡1个超量素材取除
function c6284176.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 提示玩家选择要取除的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己或对方墓地可以特殊召唤的怪兽
function c6284176.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（选择墓地的怪兽作为对象，并设置特殊召唤的操作信息）
function c6284176.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c6284176.spfilter(chkc,e,tp) end
	-- 检查自身场上是否有空余怪兽区域，以及双方墓地是否存在可特殊召唤的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c6284176.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择双方墓地1只满足特殊召唤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c6284176.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（包含对象怪兽组、数量1）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将对象怪兽特殊召唤，并使其效果无效化、种族变成植物族
function c6284176.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①锁定的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其以表侧表示特殊召唤到自己场上（分步处理）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 变成植物族
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_RACE)
		e3:SetValue(RACE_PLANT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 过滤条件：自己场上因效果而被破坏的表侧表示植物族怪兽
function c6284176.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_PLANT) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤条件：手卡或场上可用于代替解放的植物族怪兽（排除已被确定破坏的卡）
function c6284176.rfilter(c)
	return c:IsRace(RACE_PLANT) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 效果②的代替破坏判定：检查是否有植物族怪兽被效果破坏，以及自己是否有可解放的植物族怪兽
function c6284176.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c6284176.repfilter,1,nil,tp)
		-- 检查手卡·场上是否存在至少1只可用于代替解放的植物族怪兽
		and Duel.CheckReleaseGroupEx(tp,c6284176.rfilter,1,REASON_EFFECT,true,nil) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定需要代替破坏的目标怪兽是否符合过滤条件
function c6284176.repval(e,c)
	return c6284176.repfilter(c,e:GetHandlerPlayer())
end
-- 效果②的代替破坏处理：选择并解放自己手卡·场上1只植物族怪兽
function c6284176.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择用于代替破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
	-- 选择自己手卡·场上1只植物族怪兽解放
	local g=Duel.SelectReleaseGroupEx(tp,c6284176.rfilter,1,1,REASON_EFFECT,true,nil)
	-- 提示显示“六花圣 花簪剑菊”卡片发动的动画
	Duel.Hint(HINT_CARD,0,6284176)
	-- 将选中的怪兽作为代替破坏进行解放
	Duel.Release(g,REASON_EFFECT+REASON_REPLACE)
end
