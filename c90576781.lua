--レプティレス・ポイズン
-- 效果：
-- 自己场上有名字带有「爬虫妖」的怪兽表侧表示存在的场合才能发动。对方场上守备表示存在的1只怪兽变更为表侧攻击表示，那只怪兽的攻击力变成0。
function c90576781.initial_effect(c)
	-- 自己场上有名字带有「爬虫妖」的怪兽表侧表示存在的场合才能发动。对方场上守备表示存在的1只怪兽变更为表侧攻击表示，那只怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c90576781.condition)
	e1:SetTarget(c90576781.target)
	e1:SetOperation(c90576781.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「爬虫妖」怪兽
function c90576781.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3c)
end
-- 发动条件：检查自己场上是否存在表侧表示的「爬虫妖」怪兽
function c90576781.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「爬虫妖」怪兽
	return Duel.IsExistingMatchingCard(c90576781.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标选择与检测：选择对方场上1只守备表示的怪兽作为效果对象
function c90576781.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsDefensePos() end
	-- 发动检测：对方场上是否存在可以作为对象的守备表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEFENSE)  --"请选择守备表示的怪兽"
	-- 选择对方场上1只守备表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：变更表示形式的对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽变更为表侧攻击表示，并使其攻击力变成0
function c90576781.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍为守备表示且该卡效果对其有效，则将其变更为表侧攻击表示
	if tc:IsDefensePos() and tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
