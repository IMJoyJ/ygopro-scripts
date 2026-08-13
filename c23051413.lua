--ナチュル・スタッグ
-- 效果：
-- 这张卡进行攻击的战斗步骤时以及伤害步骤时对方把魔法·陷阱·效果怪兽的效果发动时，选择自己墓地存在的1只名字带有「自然」的怪兽才能发动。选择的怪兽从墓地特殊召唤。这个效果1回合只能使用1次。
function c23051413.initial_effect(c)
	-- 这张卡进行攻击的战斗步骤时以及伤害步骤时对方把魔法·陷阱·效果怪兽的效果发动时，选择自己墓地存在的1只名字带有「自然」的怪兽才能发动。选择的怪兽从墓地特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23051413,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c23051413.spcon)
	e1:SetTarget(c23051413.sptg)
	e1:SetOperation(c23051413.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，用于判断当前连锁是否满足发动前提。
function c23051413.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件判定：效果发动方是对方（rp==1-tp），且此卡是当前正在攻击的怪兽（e:GetHandler()==Duel.GetAttacker()）。
	return rp==1-tp and e:GetHandler()==Duel.GetAttacker()
end
-- 定义可特殊召唤的墓地怪兽过滤条件：必须是名字带有「自然」的怪兽，且能够被特殊召唤（符合特殊召唤条件与苏生限制）。
function c23051413.filter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标选择与合法性检查：若指定对象，则要求该对象是自己墓地的「自然」怪兽且可特殊召唤；若检查发动条件，则判断自己场上是否有空位以及墓地是否存在可特殊召唤对象。
function c23051413.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23051413.filter(chkc,e,tp) end
	-- 发动条件检查之一：自己主要怪兽区存在可用的空位，以容纳接下来要特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查之二：自己墓地存在至少1只满足条件的「自然」怪兽，可作为这个效果的对象。
		and Duel.IsExistingTarget(c23051413.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「自然」怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c23051413.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤，对象为选中的卡，数量为1，使其他卡片/效果能够正确响应此次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理时的操作：若对象卡仍与效果关联，则将其特殊召唤到己方场上。
function c23051413.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁登记的效果对象，即之前选择的那只墓地「自然」怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上，同时按常规检查其召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
