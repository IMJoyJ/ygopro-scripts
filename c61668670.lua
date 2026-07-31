--Gゴーレム・クリスタルハート
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己墓地1只地属性连接怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤，给这张卡放置1个G石人指示物。
-- ②：这张卡所互相连接区的地属性怪兽攻击力上升这张卡的G石人指示物数量×600，同1次的战斗阶段中可以作2次攻击，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c61668670.initial_effect(c)
	c:EnableCounterPermit(0x64)
	-- 连接召唤手续：电子界族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	-- ①：以自己墓地1只地属性连接怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤，给这张卡放置1个G石人指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61668670,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,61668670)
	e1:SetTarget(c61668670.sptg)
	e1:SetOperation(c61668670.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡所互相连接区的地属性怪兽攻击力上升这张卡的G石人指示物数量×600，同1次的战斗阶段中可以作2次攻击，向守备表示怪兽攻击的场合，给予对方超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c61668670.atkcon)
	e2:SetTarget(c61668670.atktg)
	e2:SetValue(c61668670.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
end
c61668670.mentioned_counter={
	[0x64]=true,
}
-- 特殊召唤目标过滤：可特殊召唤到此卡连接区的地属性连接怪兽
function c61668670.filter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ①效果发动准备：选择自己墓地1只地属性连接怪兽为对象
function c61668670.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=e:GetHandler():GetLinkedZone(tp)&0x1f
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61668670.filter(chkc,e,tp,zone) end
	-- 检查自己墓地是否存在可特殊召唤到此卡连接区的地属性连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c61668670.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只地属性连接怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61668670.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽在自己连接区特殊召唤，并给此卡放置1个G石人指示物
function c61668670.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)&0x1f
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and zone~=0 then
		-- 将对象怪兽在指定连接区表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
		c:AddCounter(0x64,1)
	end
end
-- ②效果发动条件：此卡存在互相连接状态的怪兽
function c61668670.atkcon(e)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- ②效果对象过滤：属于此卡互相连接区的地属性怪兽
function c61668670.atktg(e,c)
	local g=e:GetHandler():GetMutualLinkedGroup()
	return g:IsContains(c) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 攻击力上升数值计算：此卡的G石人指示物数量×600
function c61668670.atkval(e,c)
	return e:GetHandler():GetCounter(0x64)*600
end
