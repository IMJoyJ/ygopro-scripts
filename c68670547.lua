--闇竜の黒騎士
-- 效果：
-- ①：1回合1次，以被战斗破坏的对方墓地1只4星以下的不死族怪兽为对象才能发动。那只不死族怪兽在自己场上特殊召唤。
function c68670547.initial_effect(c)
	-- ①：1回合1次，以被战斗破坏的对方墓地1只4星以下的不死族怪兽为对象才能发动。那只不死族怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68670547,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c68670547.sptg)
	e1:SetOperation(c68670547.spop)
	c:RegisterEffect(e1)
end
-- 过滤对方墓地中等级4以下、不死族、被战斗破坏且可以特殊召唤的怪兽
function c68670547.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_ZOMBIE)
		and c:IsReason(REASON_BATTLE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与合法性检测（包括判断是否为对方墓地符合条件的卡，以及自身场上是否有空位）
function c68670547.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c68670547.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在至少1只满足条件的怪兽作为可选对象
		and Duel.IsExistingTarget(c68670547.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c68670547.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤选定卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：获取对象怪兽，若其仍存在于墓地且满足条件，则将其在自己场上特殊召唤
function c68670547.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
