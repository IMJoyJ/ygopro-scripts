--マグネット・フィールド
-- 效果：
-- 「磁力场」的①的效果1回合只能使用1次。
-- ①：自己场上有4星以下的岩石族·地属性怪兽存在的场合，以自己墓地1只4星以下的「磁石战士」怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。
-- ②：1回合1次，和自己的岩石族·地属性怪兽的战斗没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽回到持有者手卡。
function c4740489.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有4星以下的岩石族·地属性怪兽存在的场合，以自己墓地1只4星以下的「磁石战士」怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4740489,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,4740489)
	e2:SetCondition(c4740489.spcon)
	e2:SetTarget(c4740489.sptg)
	e2:SetOperation(c4740489.spop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，和自己的岩石族·地属性怪兽的战斗没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4740489,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c4740489.atcon)
	e3:SetOperation(c4740489.atop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（正面表示、4星以下、岩石族、地属性）
function c4740489.cfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_ROCK) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 效果发动条件：检查自己场上是否存在满足cfilter条件的怪兽
function c4740489.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(c4740489.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断墓地中的怪兽是否为「磁石战士」族、4星以下且可以特殊召唤
function c4740489.spfilter(c,e,tp)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择函数：当chkc不为空时，返回是否满足spfilter条件（墓地、自己控制、满足spfilter）；chk为0时，检查是否有满足条件的怪兽可特殊召唤
function c4740489.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4740489.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在满足spfilter条件的怪兽
		and Duel.IsExistingTarget(c4740489.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c4740489.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，指定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选中的怪兽特殊召唤到场上
function c4740489.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 触发条件函数：判断是否满足②效果发动条件（自己场上的岩石族·地属性怪兽参与战斗且对方怪兽未被破坏）
function c4740489.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗中的自己方和对方的怪兽
	local a,d=Duel.GetBattleMonster(tp)
	if not a or not d then return false end
	e:SetLabelObject(d)
	return a:IsRace(RACE_ROCK) and a:IsAttribute(ATTRIBUTE_EARTH)
		and d:IsRelateToBattle() and d:IsOnField()
end
-- 效果处理函数：将对方怪兽送回手牌
function c4740489.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 将目标怪兽以效果原因送回其持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
