--魔鍵召獣－アンシャラボラス
-- 效果：
-- 「魔键」怪兽＋衍生物以外的通常怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合才能发动。从自己墓地选1张「魔键-马夫提亚」加入手卡。
-- ②：1回合1次，以持有和自己墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的1只对方的攻击表示怪兽为对象才能发动。那只怪兽变成守备表示，那个守备力下降1000。
-- ③：这张卡战斗破坏的怪兽不去墓地而除外。
function c45655875.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足「魔键」字段的怪兽和满足ffilter条件的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x165),c45655875.ffilter,true)
	-- ①：这张卡融合召唤成功的场合才能发动。从自己墓地选1张「魔键-马夫提亚」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45655875,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,45655875)
	e1:SetCondition(c45655875.thcon)
	e1:SetTarget(c45655875.thtg)
	e1:SetOperation(c45655875.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以持有和自己墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的1只对方的攻击表示怪兽为对象才能发动。那只怪兽变成守备表示，那个守备力下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45655875,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c45655875.sptg)
	e2:SetOperation(c45655875.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏的怪兽不去墓地而除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断融合素材是否为通常怪兽且非衍生物
function c45655875.ffilter(c)
	return c:IsFusionType(TYPE_NORMAL) and not c:IsType(TYPE_TOKEN)
end
-- 判断此卡是否为融合召唤成功
function c45655875.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤函数，用于判断墓地是否存在「魔键-马夫提亚」且可加入手牌
function c45655875.thfilter(c)
	return c:IsCode(99426088) and c:IsAbleToHand()
end
-- 设置连锁操作信息，表示将从墓地选1张「魔键-马夫提亚」加入手牌
function c45655875.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即墓地是否存在「魔键-马夫提亚」
	if chk==0 then return Duel.IsExistingMatchingCard(c45655875.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，表示将从墓地选1张「魔键-马夫提亚」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 发动效果，提示玩家选择一张「魔键-马夫提亚」加入手牌并执行加入手牌操作
function c45655875.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择满足条件的「魔键-马夫提亚」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45655875.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断墓地的怪兽是否具有指定属性且为通常怪兽或「魔键」怪兽
function c45655875.gfilter(c,att)
	return c:IsAttribute(att) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
end
-- 过滤函数，用于判断对方攻击表示的怪兽是否可以被选为目标
function c45655875.filter(c,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
		-- 检查对方攻击表示怪兽是否具有与墓地怪兽相同属性
		and Duel.IsExistingMatchingCard(c45655875.gfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
-- 设置连锁操作信息，表示选择对方攻击表示怪兽并将其变为守备表示
function c45655875.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c45655875.filter(chkc,tp) end
	-- 检查是否满足发动条件，即对方场上是否存在符合条件的攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c45655875.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要变为守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择对方攻击表示怪兽作为目标
	local g=Duel.SelectTarget(tp,c45655875.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置连锁操作信息，表示将目标怪兽变为守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 发动效果，将目标怪兽变为守备表示并使其守备力下降1000
function c45655875.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效且处于攻击表示，然后将其变为守备表示
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		-- 为目标怪兽添加守备力下降1000的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
