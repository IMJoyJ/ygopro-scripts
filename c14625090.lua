--ドラゴンメイドのお出迎え
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽的攻击力·守备力上升自己场上的「半龙女仆」怪兽数量×100。
-- ②：自己场上有「半龙女仆」怪兽2只以上存在的场合，以「半龙女仆的迎接」以外的自己墓地1张「半龙女仆」卡为对象才能发动。那张卡加入手卡。
-- ③：这张卡被送去墓地的场合发动。这个回合中，对方不能把自己场上的「半龙女仆」怪兽作为效果的对象。
function c14625090.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽的攻击力·守备力上升自己场上的「半龙女仆」怪兽数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(c14625090.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：自己场上有「半龙女仆」怪兽2只以上存在的场合，以「半龙女仆的迎接」以外的自己墓地1张「半龙女仆」卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(14625090,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,14625090)
	e4:SetCondition(c14625090.thcon)
	e4:SetTarget(c14625090.thtg)
	e4:SetOperation(c14625090.thop)
	c:RegisterEffect(e4)
	-- ③：这张卡被送去墓地的场合发动。这个回合中，对方不能把自己场上的「半龙女仆」怪兽作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(14625090,1))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetOperation(c14625090.tgop)
	c:RegisterEffect(e5)
end
-- 过滤函数，用于判断是否为场上表侧表示的「半龙女仆」怪兽
function c14625090.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x133)
end
-- 计算攻击力时的附加值函数，返回场上「半龙女仆」怪兽数量乘以100的值
function c14625090.atkval(e,c)
	-- 获取自己场上「半龙女仆」怪兽数量并乘以100
	return Duel.GetMatchingGroupCount(c14625090.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*100
end
-- 效果发动条件函数，判断自己场上是否存在至少2只「半龙女仆」怪兽
function c14625090.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在至少2只「半龙女仆」怪兽
	return Duel.IsExistingMatchingCard(c14625090.filter,tp,LOCATION_MZONE,0,2,nil)
end
-- 过滤函数，用于判断是否为「半龙女仆」卡且不是此卡本身且可以加入手牌
function c14625090.thfilter(c)
	return c:IsSetCard(0x133) and not c:IsCode(14625090) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，选择目标墓地中的「半龙女仆」卡
function c14625090.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14625090.thfilter(chkc) end
	-- 检查是否有满足条件的墓地目标卡
	if chk==0 then return Duel.IsExistingTarget(c14625090.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择目标墓地中的「半龙女仆」卡
	local g=Duel.SelectTarget(tp,c14625090.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，指定将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动时的处理函数，将选中的卡加入手牌
function c14625090.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果发动时的处理函数，使对方不能以「半龙女仆」怪兽为对象
function c14625090.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册一个使对方不能以「半龙女仆」怪兽为对象的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果的目标为「半龙女仆」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x133))
	-- 设置效果的值为不成为对方效果对象的过滤函数
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
