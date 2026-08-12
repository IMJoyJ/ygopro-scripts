--百獣王 ベヒーモス
-- 效果：
-- 这张卡可以把1只怪兽解放作上级召唤。
-- ①：这个方法上级召唤的这张卡的原本攻击力变成2000。
-- ②：这张卡上级召唤时，以为这张卡的上级召唤而解放的怪兽数量的自己墓地的兽族怪兽为对象才能发动。那些兽族怪兽加入手卡。
function c22996376.initial_effect(c)
	-- ①：这个方法上级召唤的这张卡的原本攻击力变成2000。
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
-- 判断上级召唤的条件是否满足：等级不低于7且只需1个祭品，并检查场上是否存在满足条件的祭品。
function c22996376.otcon(e,c,minc)
	if c==nil then return true end
	-- 满足上级召唤的条件：等级不低于7且只需1个祭品，并检查场上是否存在满足条件的祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1)
end
-- 执行上级召唤的操作：选择1个祭品，将祭品从场上解放，并设置自身原本攻击力为2000。
function c22996376.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择1个用于上级召唤的祭品。
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 将选择的祭品从场上解放，作为上级召唤的代价。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	-- 设置自身原本攻击力为2000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(2000)
	c:RegisterEffect(e1)
end
-- 判断上级召唤是否成功：判断该卡是否为上级召唤方式召唤。
function c22996376.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选墓地中的兽族怪兽，这些怪兽可以被加入手牌。
function c22996376.filter(c)
	return c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- 设置上级召唤后发动的效果目标：选择与解放的怪兽数量相同的墓地兽族怪兽作为目标。
function c22996376.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c22996376.filter(chkc) end
	local ct=e:GetHandler():GetMaterialCount()
	-- 检查是否满足发动条件：解放的怪兽数量大于0且墓地存在满足条件的兽族怪兽。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c22996376.filter,tp,LOCATION_GRAVE,0,ct,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择与解放的怪兽数量相同的墓地兽族怪兽作为目标。
	local g=Duel.SelectTarget(tp,c22996376.filter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	-- 设置连锁操作信息：将选择的兽族怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,ct,0,0)
end
-- 执行上级召唤后发动的效果：将符合条件的墓地兽族怪兽加入手牌。
function c22996376.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关的已选择目标，并筛选出其中的兽族怪兽。
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsRace,nil,RACE_BEAST)
	-- 将筛选出的兽族怪兽加入手牌。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
