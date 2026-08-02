--黒羽の旋風
-- 效果：
-- ①：1回合1次，自己从额外卡组把暗属性同调怪兽特殊召唤的场合，以持有比那只怪兽低的攻击力的自己的墓地·除外状态的1只「黑羽」怪兽或「黑翼龙」为对象才能发动。那只怪兽特殊召唤。
-- ②：1回合1次，自己场上的暗属性怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个黑羽指示物取除。
function c7602800.initial_effect(c)
	-- 添加9012916（黑翼龙）到卡片记录的代码列表中
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
c7602800.mentioned_counter={
	[0x10]=true,
}
-- 过滤条件：从额外卡组特殊召唤的暗属性同调怪兽
function c7602800.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 判断是否有满足条件的怪兽特殊召唤成功
function c7602800.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(c7602800.cfilter,nil,tp)>0
end
-- 过滤条件：攻击力低于指定值、墓地或除外状态（表侧表示）的「黑羽」怪兽或「黑翼龙」，且可以特殊召唤
function c7602800.spfilter(c,e,tp,atk)
	return (c:IsSetCard(0x33) or c:IsCode(9012916)) and c:GetAttack()<atk
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 获取特殊召唤的暗属性同调怪兽中最高的攻击力，若是对象选择操作则判断对象卡是否满足上述过滤条件
function c7602800.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local _,atk=eg:Filter(c7602800.cfilter,nil,tp):GetMaxGroup(Card.GetAttack)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and c7602800.spfilter(chkc,e,tp,atk) end
	-- 效果发动条件：有可用的主要怪兽区，且
	if chk==0 then return atk and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 存在满足条件的特殊召唤对象
		and Duel.IsExistingTarget(c7602800.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,atk) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只满足条件的特殊召唤对象
	local g=Duel.SelectTarget(tp,c7602800.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,atk)
	-- 设置操作信息：包含特殊召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的操作：特殊召唤该对象怪兽
function c7602800.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将其特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的被战斗或效果破坏的暗属性怪兽
function c7602800.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否有满足条件的被破坏怪兽，且
function c7602800.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c7602800.repfilter,1,nil,tp)
		-- 自己场上可以取除1个黑羽指示物
		and Duel.IsCanRemoveCounter(tp,1,0,0x10,1,REASON_EFFECT) end
	-- 提示玩家是否取除黑羽指示物作为代替
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏处理，返回true对被破坏的暗属性怪兽适用代替效果
function c7602800.repval(e,c)
	return c7602800.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果代替破坏的操作：取除自己场上1个黑羽指示物
function c7602800.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 取除自己场上1个黑羽指示物
	Duel.RemoveCounter(tp,1,0,0x10,1,REASON_EFFECT)
end
