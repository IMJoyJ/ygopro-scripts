--黒羽の旋風
-- 效果：
-- ①：1回合1次，自己从额外卡组把暗属性同调怪兽特殊召唤的场合，以持有比那只怪兽低的攻击力的自己的墓地·除外状态的1只「黑羽」怪兽或「黑翼龙」为对象才能发动。那只怪兽特殊召唤。
-- ②：1回合1次，自己场上的暗属性怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个黑羽指示物取除。
function c7602800.initial_effect(c)
	-- 注册该卡片记有卡名「黑翼龙」（9012916）的事实。
	aux.AddCodeList(c,9012916)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己从额外卡组把暗属性同调怪兽特殊召唤的场合，以持有比那只怪兽低的攻击力的自己的墓地·除外状态的1只「黑羽」怪兽或「黑翼龙」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7602800,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c7602800.spcon)
	e2:SetTarget(c7602800.sptg)
	e2:SetOperation(c7602800.spop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上的暗属性怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个黑羽指示物取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c7602800.reptg)
	e3:SetValue(c7602800.repval)
	e3:SetOperation(c7602800.repop)
	c:RegisterEffect(e3)
end
-- 过滤出由自己从额外卡组特殊召唤的暗属性同调怪兽。
function c7602800.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 判定是否发生了自己从额外卡组特殊召唤暗属性同调怪兽的事件。
function c7602800.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(c7602800.cfilter,nil,tp)>0
end
-- 过滤出自己墓地或除外状态下，攻击力低于指定数值且可以特殊召唤的「黑羽」怪兽或「黑翼龙」。
function c7602800.spfilter(c,e,tp,atk)
	return (c:IsSetCard(0x33) or c:IsCode(9012916)) and c:GetAttack()<atk
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与对象选择，获取特殊召唤的怪兽中的最大攻击力并进行对象合法性检查。
function c7602800.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local _,atk=eg:Filter(c7602800.cfilter,nil,tp):GetMaxGroup(Card.GetAttack)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and c7602800.spfilter(chkc,e,tp,atk) end
	-- 检查是否存在合法的攻击力数值，以及自己场上是否有可用的怪兽区域空格。
	if chk==0 then return atk and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的墓地或除外状态下是否存在满足特殊召唤条件的合法对象。
		and Duel.IsExistingTarget(c7602800.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,atk) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地或除外状态下的1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c7602800.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,atk)
	-- 设置连锁处理的操作信息，表明此效果包含特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理，将选择的对象怪兽特殊召唤。
function c7602800.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤出自己场上因战斗或效果而被破坏的表侧表示暗属性怪兽。
function c7602800.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的准备与判定，检查是否有符合条件的暗属性怪兽被破坏以及是否能移除黑羽指示物。
function c7602800.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c7602800.repfilter,1,nil,tp)
		-- 检查自己场上是否可以因效果移除1个黑羽指示物。
		and Duel.IsCanRemoveCounter(tp,1,0,0x10,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 过滤并确定哪些被破坏的怪兽适用此代替破坏效果。
function c7602800.repval(e,c)
	return c7602800.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的效果处理，执行移除指示物的操作。
function c7602800.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 移除自己场上的1个黑羽指示物。
	Duel.RemoveCounter(tp,1,0,0x10,1,REASON_EFFECT)
end
