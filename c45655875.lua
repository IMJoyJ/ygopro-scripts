--魔鍵召獣－アンシャラボラス
-- 效果：
-- 「魔键」怪兽＋衍生物以外的通常怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合才能发动。从自己墓地选1张「魔键-马夫提亚」加入手卡。
-- ②：1回合1次，以持有和自己墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的1只对方的攻击表示怪兽为对象才能发动。那只怪兽变成守备表示，那个守备力下降1000。
-- ③：这张卡战斗破坏的怪兽不去墓地而除外。
function c45655875.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为1只「魔键」怪兽（卡名含有0x165）和1只衍生物以外的通常怪兽（ffilter），以此作为融合素材进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x165),c45655875.ffilter,true)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡融合召唤成功的场合才能发动。从自己墓地选1张「魔键-马夫提亚」加入手卡。
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
-- 定义融合素材过滤器：素材怪兽必须是通常怪兽且不是衍生物（即衍生物以外的通常怪兽）。
function c45655875.ffilter(c)
	return c:IsFusionType(TYPE_NORMAL) and not c:IsType(TYPE_TOKEN)
end
-- ①效果发动条件：这张卡是以融合召唤方式特殊召唤成功（召唤类型为融合召唤）。
function c45655875.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索过滤器：选择墓地里卡名为「魔键-马夫提亚」（99426088）且可以加入手卡的卡。
function c45655875.thfilter(c)
	return c:IsCode(99426088) and c:IsAbleToHand()
end
-- ①效果的发动目标判定：己方墓地存在符合条件的「魔键-马夫提亚」时，效果可以发动；并设置操作信息为把墓地的卡加入手卡。
function c45655875.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：检查己方墓地是否存在至少1张满足thfilter的「魔键-马夫提亚」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c45655875.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本效果处理后要从墓地取1张卡加入手卡（CATEGORY_TOHAND），位置为己方墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从自己墓地选择1张符合条件的「魔键-马夫提亚」（过滤王家长眠之谷影响），将其加入持有者手卡。
function c45655875.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 执行选择：从己方墓地选择1张满足条件且不受王家长眠之谷影响的「魔键-马夫提亚」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45655875.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡送去其持有者的手卡，操作原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 定义墓地卡过滤器：用于判断墓地中的卡是否为通常怪兽或「魔键」怪兽，且属性与指定属性相同；用于②效果中对照对象属性。
function c45655875.gfilter(c,att)
	return c:IsAttribute(att) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
end
-- 定义②效果可选择的对象怪兽条件：对方场上的表侧攻击表示怪兽，可以变更表示形式，且自己墓地存在至少1只与之属性相同的通常怪兽或「魔键」怪兽。
function c45655875.filter(c,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
		-- 追加条件：自己墓地存在与对象怪兽属性相同的通常怪兽或「魔键」怪兽。
		and Duel.IsExistingMatchingCard(c45655875.gfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
-- ②效果的发动阶段：选择对方场上1只满足filter的表侧攻击表示怪兽作为对象；并设置操作信息为改变表示形式。
function c45655875.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c45655875.filter(chkc,tp) end
	-- 发动合法性检查：对方场上是否存在满足filter的表侧攻击表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c45655875.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 显示选择提示：请选择表侧攻击表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 执行选择：从对方怪兽区域选择1只满足条件的攻击表示怪兽作为对象，并建立效果关联。
	local g=Duel.SelectTarget(tp,c45655875.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：本效果将变更对象怪兽的表示形式（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：将对象怪兽变成表侧守备表示；如果变更成功，则给对象怪兽附加守备力下降1000的效果。
function c45655875.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时关联的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联且仍为表侧攻击表示，然后将其变为表侧守备表示；变更成功（返回非0）才继续执行后续守备力下降处理。
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		-- 那个守备力下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
