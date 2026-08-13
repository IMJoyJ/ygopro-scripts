--BF－疾風のゲイル
-- 效果：
-- ①：自己场上有「黑羽-疾风之盖尔」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力变成一半。
function c2009101.initial_effect(c)
	-- ①：自己场上有「黑羽-疾风之盖尔」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c2009101.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2009101,0))  --"攻防减半"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c2009101.target)
	e2:SetOperation(c2009101.operation)
	c:RegisterEffect(e2)
end
-- 筛选符合条件的「黑羽」怪兽：必须表侧表示、属于「黑羽」字段，且不能是「黑羽-疾风之盖尔」自身，用于①效果的自定义特殊召唤条件。
function c2009101.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and not c:IsCode(2009101)
end
-- ①效果的特殊召唤规则条件：当这张卡在手牌时，若其控制者场上有空余的主要怪兽区域，并且场上存在满足filter的「黑羽」怪兽，则可以从手卡特殊召唤；c为nil时视为规则询问的默认允许。
function c2009101.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者场上是否还有可用的主要怪兽区域，确保能从手卡特殊召唤到场上。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查这张卡的控制者场上是否存在至少1只满足filter（表侧表示且非自身的「黑羽」怪兽）的怪兽，满足①效果的自定义特召前提。
		Duel.IsExistingMatchingCard(c2009101.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动目标选择处理：只能以对方场上1只表侧表示怪兽为对象，包括对象合法性判断和选择卡片的操作。
function c2009101.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 效果发动时的合法性检查：确认对方场上是否存在至少1只表侧表示怪兽可以作为②效果的对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示，用于引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作者从对方场上选择1张表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：取得对象怪兽后，若对象仍在场上且表侧表示、与效果关联，则将其攻击力和守备力各变为当前值的一半（向上取整），并注册暂时变更效果。
function c2009101.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动②效果时选择的对象怪兽（这里只取第一个对象，也是唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只对方怪兽的攻击力变成一半（对应原文“攻击力·守备力变成一半”中的攻击力部分）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
		-- 那只对方怪兽的守备力变成一半（对应原文“攻击力·守备力变成一半”中的守备力部分）。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		tc:RegisterEffect(e2)
	end
end
