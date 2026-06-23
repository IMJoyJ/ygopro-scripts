--転生炎獣の聖域
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：只要这张卡在场地区域存在，自己要把「转生炎兽」连接怪兽连接召唤的场合，可以只用自己场上1只同名「转生炎兽」连接怪兽为素材作连接召唤。
-- ②：自己怪兽进行战斗的伤害计算时，支付1000基本分，以自己场上1只连接怪兽为对象才能发动。那只怪兽的攻击力变成0，自己基本分回复那只怪兽的原本攻击力的数值。
function c1295111.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己要把「转生炎兽」连接怪兽连接召唤的场合，可以只用自己场上1只同名「转生炎兽」连接怪兽为素材作连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1295111,0))  --"只使用同名怪兽为素材连接召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCountLimit(1,1295111)
	e2:SetCondition(c1295111.linkcon)
	e2:SetOperation(c1295111.linkop)
	e2:SetValue(SUMMON_TYPE_LINK)
	-- ②：自己怪兽进行战斗的伤害计算时，支付1000基本分，以自己场上1只连接怪兽为对象才能发动。那只怪兽的攻击力变成0，自己基本分回复那只怪兽的原本攻击力的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetTarget(c1295111.mattg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 只使用同名怪兽为素材连接召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1295111,1))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetCountLimit(1,1295112)
	e4:SetCondition(c1295111.atkcon)
	e4:SetCost(c1295111.atkcost)
	e4:SetTarget(c1295111.atktg)
	e4:SetOperation(c1295111.atkop)
	c:RegisterEffect(e4)
end
-- 只使用同名怪兽为素材连接召唤
function c1295111.lmfilter(c,lc,tp,og,lmat)
	return c:IsFaceup() and c:IsCanBeLinkMaterial(lc) and c:IsLinkCode(lc:GetCode()) and c:IsLinkType(TYPE_LINK)
		-- 满足连接召唤条件的素材必须满足的条件：有足够召唤空间且必须成为素材
		and Duel.GetLocationCountFromEx(tp,tp,c,lc)>0 and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_LMATERIAL)
		and (not og or og:IsContains(c)) and (not lmat or lmat==c)
end
-- 连接召唤的条件函数，检查是否存在满足条件的素材
function c1295111.linkcon(e,c,og,lmat,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否存在满足连接召唤条件的素材
	return Duel.IsExistingMatchingCard(c1295111.lmfilter,tp,LOCATION_MZONE,0,1,nil,c,tp,og,lmat)
end
-- 连接召唤的操作函数，选择并处理素材
function c1295111.linkop(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
	-- 选择满足连接召唤条件的素材
	local mg=Duel.SelectMatchingCard(tp,c1295111.lmfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp,og,lmat)
	c:SetMaterial(mg)
	-- 将选择的素材送入墓地作为连接召唤的代价
	Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_LINK)
end
-- 判断是否为转生炎兽系列的连接怪兽
function c1295111.mattg(e,c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_LINK)
end
-- 判断是否为转生炎兽系列的连接怪兽
function c1295111.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 如果攻击怪兽不是自己，则获取攻击目标怪兽
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
	return a
end
-- 支付1000基本分作为发动代价
function c1295111.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 判断是否为正面表示的连接怪兽且攻击力不为0
function c1295111.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and not c:IsAttack(0)
end
-- 选择目标连接怪兽并设置操作信息
function c1295111.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1295111.atkfilter(chkc) end
	-- 检查是否存在满足条件的连接怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c1295111.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标连接怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择目标连接怪兽
	local g=Duel.SelectTarget(tp,c1295111.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local rec=g:GetFirst():GetBaseAttack()
	-- 设置目标怪兽的攻击力作为操作参数
	Duel.SetTargetParam(rec)
	-- 设置回复LP的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 处理效果的最终操作：改变目标怪兽攻击力并回复LP
function c1295111.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 将目标怪兽的攻击力设置为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 回复目标怪兽原本攻击力数值的LP
		Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
