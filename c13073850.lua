--クリフォート・エイリアス
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
-- ②：自己场上的「机壳」怪兽的攻击力上升300。
-- 【怪兽效果】
-- ①：这张卡可以不用解放作召唤。
-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ④：把「机壳」怪兽解放对这张卡的上级召唤成功时，以场上1张卡为对象才能发动。那张卡回到持有者手卡。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
function c13073850.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c13073850.splimcon)
	e2:SetTarget(c13073850.splimit)
	c:RegisterEffect(e2)
	-- ②：自己场上的「机壳」怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 选择场上所有「机壳」怪兽作为效果的对象
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xaa))
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- ①：这张卡可以不用解放作召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13073850,0))  --"不用解放作召唤"
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetCondition(c13073850.ntcon)
	c:RegisterEffect(e4)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_COST)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(c13073850.lvop)
	c:RegisterEffect(e5)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SPSUMMON_COST)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(c13073850.lvop2)
	c:RegisterEffect(e6)
	-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c13073850.immcon)
	-- 设置该效果为机壳怪兽通用抗性（不受原本等级·阶级比这张卡等级低的怪兽效果影响）的过滤函数
	e7:SetValue(aux.qlifilter)
	c:RegisterEffect(e7)
	-- ④：把「机壳」怪兽解放对这张卡的上级召唤成功时，以场上1张卡为对象才能发动。那张卡回到持有者手卡。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(13073850,1))  --"弹回手卡"
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e8:SetCondition(c13073850.thcon)
	e8:SetTarget(c13073850.thtg)
	e8:SetOperation(c13073850.thop)
	c:RegisterEffect(e8)
	-- 当此卡被加入手牌或特殊召唤时，检查其是否使用了「机壳」怪兽作为素材，若使用则设置标记为1，否则为0
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_MATERIAL_CHECK)
	e9:SetValue(c13073850.valcheck)
	e9:SetLabelObject(e8)
	c:RegisterEffect(e9)
end
-- 判断灵摆区域的卡是否被禁止使用
function c13073850.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
-- 判断被特殊召唤的怪兽是否为「机壳」怪兽
function c13073850.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 判断是否满足不用解放作召唤的条件
function c13073850.ntcon(e,c,minc)
	if c==nil then return true end
	-- 召唤等级不低于5且场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断是否满足等级和攻击力变更的条件
function c13073850.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
end
-- 处理召唤时等级和攻击力变更效果
function c13073850.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡等级变为4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c13073850.lvcon)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	-- 将此卡原本攻击力变为1800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c13073850.lvcon)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e2)
end
-- 处理特殊召唤时等级和攻击力变更效果
function c13073850.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡等级变为4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e1)
	-- 将此卡原本攻击力变为1800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为通常召唤
function c13073850.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 判断上级召唤成功且使用了「机壳」怪兽作为素材
function c13073850.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 设置选择目标时的处理函数
function c13073850.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 判断是否存在可选择的目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 选择场上1张可送回手牌的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息为将目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁限制为只能由发动者连锁
	Duel.SetChainLimit(c13073850.chlimit)
end
-- 连锁限制函数，只允许发动者连锁
function c13073850.chlimit(e,ep,tp)
	return tp==ep
end
-- 处理将目标卡送回手牌的效果
function c13073850.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 检查此卡是否使用了「机壳」怪兽作为素材
function c13073850.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0xaa) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
