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
	-- 为这张灵摆怪兽添加灵摆召唤相关属性，使其可以作为灵摆卡在灵摆区发动并支持灵摆召唤。
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
	-- 设置效果的作用对象为“我方场上表侧表示的「机壳」怪兽”，只有这些怪兽才适用攻击力上升效果。
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
	-- ②：不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_COST)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(c13073850.lvop)
	c:RegisterEffect(e5)
	-- ②：特殊召唤的这张卡的等级变成4星，原本攻击力变成1800。
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
	-- 将免疫判定设为机壳通用抗性函数，根据发动效果的怪兽原本等级/阶级与这张卡当前等级比较来决定是否免疫。
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
	-- ④：把「机壳」怪兽解放对这张卡的上级召唤成功时。
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_MATERIAL_CHECK)
	e9:SetValue(c13073850.valcheck)
	e9:SetLabelObject(e8)
	c:RegisterEffect(e9)
end
-- 灵摆区特殊召唤限制的适用条件：这张灵摆卡在灵摆区且未被禁止使用（IsForbidden为false）时才适用该限制。
function c13073850.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
-- 特殊召唤限制判定：不允许特殊召唤不是「机壳」字段的怪兽。
function c13073850.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 无解放召唤规则的条件判断：若正在召唤的卡是这张卡自身，则要求无需解放（minc==0）、该卡等级5以上且我方怪兽区有空位。
function c13073850.ntcon(e,c,minc)
	if c==nil then return true end
	-- 确认无解放召唤所需条件：召唤不需解放、这张卡等级≥5、我方怪兽区有空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判定这张卡的素材数量为0（用于只在无解放召唤/未叠放素材的情况下维持等级与攻击力的变更）。
function c13073850.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
end
-- 不用解放作召唤成功时，给这张卡注册“等级变为4星”和“原本攻击力变为1800”的持续效果，并在离场/改变位置时重置。
function c13073850.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：不用解放作召唤的这张卡的等级变成4星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c13073850.lvcon)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	-- ②：不用解放作召唤的这张卡的原本攻击力变成1800。
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
-- 特殊召唤成功时，给这张卡注册“等级变为4星”和“原本攻击力变为1800”的持续效果，并在离场/改变位置时重置。
function c13073850.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：特殊召唤的这张卡的等级变成4星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e1)
	-- ②：特殊召唤的这张卡的原本攻击力变成1800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e2)
end
-- 免疫效果的适用条件：这张卡是以通常召唤方式（包括无解放通常召唤）成功召唤的场合。
function c13073850.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 弹回手卡效果的发动条件：这张卡是上级召唤成功，并且其解放素材中含有「机壳」怪兽（e:GetLabel()==1）。
function c13073850.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 发动时选择场上1张能弹回手卡的卡为对象，设置回手牌操作信息，并追加连锁限制使对方不能对应本效果发动魔法·陷阱·怪兽效果。
function c13073850.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 效果发动合法性检查：确认场上存在至少1张可以被弹回手卡的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家弹出“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择场上1张可以弹回手卡的卡作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次效果将对象卡弹回持有者手牌，供星尘龙等卡进行效果相关判定/连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁限制，只允许效果发动者自己连锁此效果，使对方不能对应发动魔法·陷阱·怪兽效果。
	Duel.SetChainLimit(c13073850.chlimit)
end
-- 连锁限制判定：只有连锁发动方与效果发动玩家相同才允许连锁（即对方不能连锁）。
function c13073850.chlimit(e,ep,tp)
	return tp==ep
end
-- 弹回手卡效果处理：取得对象卡，若对象仍与该效果关联，则将其送回持有者手卡。
function c13073850.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 上级召唤成功时的素材检查：若素材中存在「机壳」怪兽，则将弹回手卡效果的Label设为1（满足④发动条件），否则设为0。
function c13073850.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0xaa) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
