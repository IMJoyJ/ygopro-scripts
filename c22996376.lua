--百獣王 ベヒーモス
-- 效果：
-- 这张卡可以把1只怪兽解放作上级召唤。
-- ①：这个方法上级召唤的这张卡的原本攻击力变成2000。
-- ②：这张卡上级召唤时，以为这张卡的上级召唤而解放的怪兽数量的自己墓地的兽族怪兽为对象才能发动。那些兽族怪兽加入手卡。
function c22996376.initial_effect(c)
	-- 这张卡可以把1只怪兽解放作上级召唤；①：这个方法上级召唤的这张卡的原本攻击力变成2000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22996376,0))  --"把1只怪兽解放作上级召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c22996376.otcon)
	e1:SetOperation(c22996376.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ②：这张卡上级召唤时，以为这张卡的上级召唤而解放的怪兽数量的自己墓地的兽族怪兽为对象才能发动。那些兽族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22996376,1))  --"返回手牌"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c22996376.thcon)
	e3:SetTarget(c22996376.thtg)
	e3:SetOperation(c22996376.thop)
	c:RegisterEffect(e3)
end
-- 判断能否以1只怪兽解放进行上级召唤：卡为7星以上、解放数量不超过1、且场上存在可解放的祭品。
function c22996376.otcon(e,c,minc)
	if c==nil then return true end
	-- 返回真当该怪兽等级≥7、本次召唤要求解放数≤1，且场上（或可选择祭品组中）存在1只可用作上级召唤的祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1)
end
-- 执行上级召唤手续：选择1只怪兽解放并设为素材；解放该怪兽；随后为此卡设置“原本攻击力变为2000”的效果。
function c22996376.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择1只解放用的怪兽（祭品）。
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 将选中的怪兽作为上级召唤的素材解放（原因包含召唤和素材）。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	-- ①：这个方法上级召唤的这张卡的原本攻击力变成2000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(2000)
	c:RegisterEffect(e1)
end
-- 返回真当这张卡的召唤类型是上级召唤（SUMMON_TYPE_ADVANCE）。
function c22996376.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选位于自己墓地、种族为兽族且可以被加入手卡的怪兽。
function c22996376.filter(c)
	return c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- ②效果发动时的取对象处理：要求从自己墓地选择『为这张卡上级召唤而解放的怪兽数量』的兽族怪兽；若墓地可选的兽族怪兽达到该数量且大于0才能发动，发动后选择那些卡并设置回手牌信息。
function c22996376.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c22996376.filter(chkc) end
	local ct=e:GetHandler():GetMaterialCount()
	-- 发动合法性检查：解放数ct必须大于0，且自己墓地存在至少ct张满足筛选条件的兽族怪兽可供选择。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c22996376.filter,tp,LOCATION_GRAVE,0,ct,nil) end
	-- 显示选择提示‘请选择要返回手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己墓地的兽族怪兽中选择ct张作为对象（同时设定为连锁对象）。
	local g=Duel.SelectTarget(tp,c22996376.filter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	-- 设置操作信息：本次效果会把所选的ct张卡返回手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,ct,0,0)
end
-- 效果处理：取得效果对象中仍相关的兽族怪兽，将其返回持有者手牌。
function c22996376.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁上仍存在关联的对象，并筛选出种族为兽族的怪兽。
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsRace,nil,RACE_BEAST)
	-- 将筛选出的兽族怪兽加入持有者手牌（REASON_EFFECT）。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
