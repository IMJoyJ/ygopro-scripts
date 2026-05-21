--クリフォート・アーカイブ
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
-- ②：自己场上的「机壳」怪兽的攻击力上升300。
-- 【怪兽效果】
-- ①：这张卡可以不用解放作召唤。
-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ④：这张卡被解放的场合，以场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
function c91907707.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c91907707.splimit)
	c:RegisterEffect(e2)
	-- ②：自己场上的「机壳」怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤出场上字段为「机壳」的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xaa))
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- ①：这张卡可以不用解放作召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(91907707,0))  --"不用解放作召唤"
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetCondition(c91907707.ntcon)
	c:RegisterEffect(e4)
	-- ②：不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_COST)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(c91907707.lvop)
	c:RegisterEffect(e5)
	-- ②：特殊召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SPSUMMON_COST)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(c91907707.lvop2)
	c:RegisterEffect(e6)
	-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c91907707.immcon)
	-- 设置不受原本等级或阶级比这张卡等级低的怪兽发动的效果影响的过滤条件
	e7:SetValue(aux.qlifilter)
	c:RegisterEffect(e7)
	-- ④：这张卡被解放的场合，以场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(91907707,1))  --"回到手卡"
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_RELEASE)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e8:SetTarget(c91907707.thtg)
	e8:SetOperation(c91907707.thop)
	c:RegisterEffect(e8)
end
-- 限制只能特殊召唤「机壳」怪兽
function c91907707.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 判定是否满足不用解放作召唤的条件
function c91907707.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定解放数量为0、怪兽原本等级在5星以上且场上有可用怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判定这张卡召唤时没有使用解放的祭品
function c91907707.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
end
-- 注册不用解放作召唤时的等级和原本攻击力变更效果
function c91907707.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：不用解放作召唤的这张卡的等级变成4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c91907707.lvcon)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	-- ②：不用解放作召唤的这张卡的原本攻击力变成1800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c91907707.lvcon)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e2)
end
-- 注册特殊召唤时的等级和原本攻击力变更效果
function c91907707.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：特殊召唤的这张卡的等级变成4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e1)
	-- ②：特殊召唤的这张卡的原本攻击力变成1800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e2)
end
-- 判定这张卡是否为通常召唤
function c91907707.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 判定并选择要回到持有者手卡的对象怪兽
function c91907707.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 判定场上是否存在可以回到手卡的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1只可以回到手卡的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为将选中的1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行将对象怪兽送回手牌的效果处理
function c91907707.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
