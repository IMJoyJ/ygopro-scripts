--スクラップ・オルトロス
-- 效果：
-- 这张卡不能通常召唤。自己场上有「废铁」怪兽存在的场合可以特殊召唤。
-- ①：这个方法让这张卡特殊召唤成功的场合，以自己场上1只「废铁」怪兽为对象发动。那只自己的「废铁」怪兽破坏。
-- ②：这张卡被「废铁」卡的效果破坏送去墓地的场合，以「废铁双头犬」以外的自己墓地1只「废铁」怪兽为对象才能发动。那只怪兽加入手卡。
function c64550682.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上有「废铁」怪兽存在的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c64550682.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ①：这个方法让这张卡特殊召唤成功的场合，以自己场上1只「废铁」怪兽为对象发动。那只自己的「废铁」怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64550682,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c64550682.descon)
	e2:SetTarget(c64550682.destg)
	e2:SetOperation(c64550682.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡被「废铁」卡的效果破坏送去墓地的场合，以「废铁双头犬」以外的自己墓地1只「废铁」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64550682,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c64550682.thcon)
	e3:SetTarget(c64550682.thtg)
	e3:SetOperation(c64550682.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「废铁」怪兽
function c64550682.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x24)
end
-- 特殊召唤规则的条件：自身怪兽区域有空位，且自己场上存在表侧表示的「废铁」怪兽
function c64550682.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的主要怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「废铁」怪兽
		and Duel.IsExistingMatchingCard(c64550682.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动条件：这张卡是通过自身效果特殊召唤成功的场合
function c64550682.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：自己场上表侧表示的「废铁」怪兽
function c64550682.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x24)
end
-- 效果①的靶向处理（选择自己场上1只表侧表示的「废铁」怪兽作为破坏对象）
function c64550682.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c64550682.desfilter(chkc) end
	if chk==0 then return true end
	-- 给玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的「废铁」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c64550682.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息：包含破坏分类，操作对象为选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的运行空间（破坏作为对象的「废铁」怪兽）
function c64550682.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡被「废铁」卡的效果破坏并送去墓地
function c64550682.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and re:GetOwner():IsSetCard(0x24)
end
-- 过滤条件：自己墓地中「废铁双头犬」以外的「废铁」怪兽且能加入手卡
function c64550682.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and not c:IsCode(64550682) and c:IsAbleToHand()
end
-- 效果②的靶向处理（选择自己墓地1只「废铁双头犬」以外的「废铁」怪兽作为加入手卡的对象）
function c64550682.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c64550682.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在符合条件的「废铁」怪兽
	if chk==0 then return Duel.IsExistingTarget(c64550682.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的「废铁」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c64550682.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息：包含加入手卡分类，操作数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的运行空间（将选中的墓地怪兽加入手卡并给对方确认）
function c64550682.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
