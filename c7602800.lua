--黒羽の旋風
-- 效果：
-- ①：1回合1次，自己从额外卡组把暗属性同调怪兽特殊召唤的场合，以持有比那只怪兽低的攻击力的自己的墓地·除外状态的1只「黑羽」怪兽或「黑翼龙」为对象才能发动。那只怪兽特殊召唤。
-- ②：1回合1次，自己场上的暗属性怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个黑羽指示物取除。
function c7602800.initial_effect(c)
	-- 注册关联卡名列表：「黑翼龙」(9012916)
	aux.AddCodeList(c,9012916)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己从额外卡组把暗属性同调怪兽特殊召唤的场合，以持有比那种怪兽低的攻击力的自己的墓地·除外状态的1只「黑羽」怪兽或「黑翼龙」为对象才能发动。那只怪兽特殊召唤。
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
	-- ②：1回合1次，自己场上的暗属性怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1个黑羽指示物去除。
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
-- 触发事件过滤：由自己从额外卡组特殊召唤的暗属性同调怪兽
function c7602800.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- ①效果发动条件检查：触发事件的怪兽中存在符合条件的暗属性同调怪兽
function c7602800.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(c7602800.cfilter,nil,tp)>0
end
-- 特召目标过滤条件：墓地/除外状态攻击力低于指定值且可特召的「黑羽」怪兽或「黑翼龙」
function c7602800.spfilter(c,e,tp,atk)
	return (c:IsSetCard(0x33) or c:IsCode(9012916)) and c:GetAttack()<atk
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动准备与目标选择
function c7602800.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local _,atk=eg:Filter(c7602800.cfilter,nil,tp):GetMaxGroup(Card.GetAttack)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and c7602800.spfilter(chkc,e,tp,atk) end
	-- 发动条件检查：计算出攻击力上限且自己怪兽区域有空位
	if chk==0 then return atk and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且墓地或除外状态存在满足条件的特召目标
		and Duel.IsExistingTarget(c7602800.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,atk) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地或除外状态1只满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c7602800.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,atk)
	-- 设置连锁操作信息：特殊召唤1张目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将选中的目标怪兽特殊召唤
function c7602800.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 替代破坏过滤条件：自己场上表侧表示因战斗·效果破坏的暗属性怪兽
function c7602800.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②效果（替代破坏）发动准备与条件检查
function c7602800.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c7602800.repfilter,1,nil,tp)
		-- 发动条件检查：场上能够去除1个黑羽指示物
		and Duel.IsCanRemoveCounter(tp,1,0,0x10,1,REASON_EFFECT) end
	-- 询问玩家是否选择发动替代破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回是否为需要受保护的暗属性怪兽
function c7602800.repval(e,c)
	return c7602800.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果处理：去除黑羽指示物以代替破坏
function c7602800.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 从场上去除1个黑羽指示物
	Duel.RemoveCounter(tp,1,0,0x10,1,REASON_EFFECT)
end
