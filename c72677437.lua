--毒蛇王ヴェノミノン
-- 效果：
-- 这张卡不能用这张卡以外的效果怪兽的效果特殊召唤。这张卡的攻击力上升自己墓地的爬虫类族怪兽数量×500的数值。这张卡只要在场上表侧表示存在，不受「蛇毒沼泽」的效果影响。这张卡被战斗破坏送去墓地时，可以通过把这张卡以外的自己墓地1只爬虫类族怪兽从游戏中除外，这张卡特殊召唤。
function c72677437.initial_effect(c)
	-- 在卡片中注册记载了「蛇毒沼泽」（卡号54306223）的卡片密码
	aux.AddCodeList(c,54306223)
	-- 这张卡不能用这张卡以外的效果怪兽的效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c72677437.splimit)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升自己墓地的爬虫类族怪兽数量×500的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c72677437.atkval)
	c:RegisterEffect(e2)
	-- 这张卡被战斗破坏送去墓地时，可以通过把这张卡以外的自己墓地1只爬虫类族怪兽从游戏中除外，这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72677437,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c72677437.condition)
	e3:SetCost(c72677437.cost)
	e3:SetTarget(c72677437.target)
	e3:SetOperation(c72677437.operation)
	c:RegisterEffect(e3)
	-- 这张卡只要在场上表侧表示存在，不受「蛇毒沼泽」的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c72677437.efilter)
	c:RegisterEffect(e4)
end
-- 特殊召唤限制判定函数，限制不能被自身以外的效果怪兽的效果特殊召唤
function c72677437.splimit(e,se,sp,st)
	return not se:GetHandler():IsType(TYPE_MONSTER)
end
-- 攻击力数值计算函数，根据自己墓地的爬虫类族怪兽数量计算增加的攻击力
function c72677437.atkval(e,c)
	-- 获取自己墓地爬虫类族怪兽的数量并乘以500作为攻击力上升值
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_REPTILE)*500
end
-- 特殊召唤效果的发动条件：自身被战斗破坏并送去墓地
function c72677437.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤自己墓地中可以作为代价除外的爬虫类族怪兽
function c72677437.cfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的发动代价：将自身以外的自己墓地1只爬虫类族怪兽除外
function c72677437.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在除自身以外的至少1只爬虫类族怪兽可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(c72677437.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家发送选择除外卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地中除自身以外的1只爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,c72677437.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的怪兽表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的发动目标：确认自己场上有空位且自身可以特殊召唤
function c72677437.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理：将自身特殊召唤到场上
function c72677437.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示无视召唤条件特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 免疫效果过滤器，判定来源效果是否为「蛇毒沼泽」
function c72677437.efilter(e,te)
	return te:GetHandler():IsCode(54306223)
end
