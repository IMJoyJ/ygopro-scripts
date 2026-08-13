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
	-- ①：只要这张卡在场地区域存在，自己要把「转生炎兽」连接怪兽连接召唤的场合，可以只用自己场上1只同名「转生炎兽」连接怪兽为素材作连接召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetTarget(c1295111.mattg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：自己怪兽进行战斗的伤害计算时，支付1000基本分，以自己场上1只连接怪兽为对象才能发动。那只怪兽的攻击力变成0，自己基本分回复那只怪兽的原本攻击力的数值。
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
-- 判断候选怪兽能否作为同名「转生炎兽」连接召唤素材：要求表侧表示、可作为连接素材、与召唤怪兽卡名相同、是连接怪兽、额外怪兽区有空位、未受“必须作为连接素材”限制，且包含在给定的可用素材集合内。
function c1295111.lmfilter(c,lc,tp,og,lmat)
	return c:IsFaceup() and c:IsCanBeLinkMaterial(lc) and c:IsLinkCode(lc:GetCode()) and c:IsLinkType(TYPE_LINK)
		-- 确认该素材送墓后额外怪兽区仍有空位，且素材本身没有“必须作为连接素材”之类的限制。
		and Duel.GetLocationCountFromEx(tp,tp,c,lc)>0 and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_LMATERIAL)
		and (not og or og:IsContains(c)) and (not lmat or lmat==c)
end
-- 判断是否满足仅用1只同名「转生炎兽」连接怪兽作为素材进行连接召唤的条件；若c为空则默认允许。
function c1295111.linkcon(e,c,og,lmat,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足lmfilter条件的同名「转生炎兽」连接怪兽可作为连接素材。
	return Duel.IsExistingMatchingCard(c1295111.lmfilter,tp,LOCATION_MZONE,0,1,nil,c,tp,og,lmat)
end
-- 执行连接召唤的素材处理：从自己场上选出1只符合条件的同名「转生炎兽」连接怪兽，将其设定为素材并送入墓地，完成仅用1只同名怪兽作素材的连接召唤。
function c1295111.linkop(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
	-- 从自己场上选择1只满足lmfilter条件的同名「转生炎兽」连接怪兽作为本次连接召唤的素材。
	local mg=Duel.SelectMatchingCard(tp,c1295111.lmfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp,og,lmat)
	c:SetMaterial(mg)
	-- 将所选连接素材作为连接召唤的素材送去墓地（送墓原因同时包含作为素材与连接召唤）。
	Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_LINK)
end
-- e3的授予对象过滤：只有「转生炎兽」连接怪兽才能获得“只用同名怪兽作连接素材”的特殊召唤规则效果。
function c1295111.mattg(e,c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_LINK)
end
-- ②效果的发动条件：伤害计算时存在己方怪兽进行战斗。若攻击者是对方怪兽则改看被攻击者，被攻击者为己方怪兽时条件成立。
function c1295111.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在进行伤害计算的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 如果攻击者是对方怪兽，则将判定对象改为被攻击的己方怪兽。
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
	return a
end
-- ②效果的发动代价：支付1000基本分。
function c1295111.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己能否支付1000基本分作为代价。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- ②效果的对象筛选：表侧表示的连接怪兽，且当前攻击力不为0。
function c1295111.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and not c:IsAttack(0)
end
-- ②效果发动时的目标选择与操作信息设定：取自己场上1只表侧且攻击力不为0的连接怪兽为对象，记录其原本攻击力用于回复。
function c1295111.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1295111.atkfilter(chkc) end
	-- 检查自己场上是否存在至少1只满足atkfilter的合法对象。
	if chk==0 then return Duel.IsExistingTarget(c1295111.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作者显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只满足条件的表侧表示连接怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c1295111.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local rec=g:GetFirst():GetBaseAttack()
	-- 将所选对象怪兽的原本攻击力设为该连锁的参数，供后续恢复时使用。
	Duel.SetTargetParam(rec)
	-- 设置本次效果的操作信息，登记回复基本伤的分类与数值，用于连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- ②效果处理：使对象连接怪兽攻击力变成0，然后自己回复其原本攻击力数值的基本分。
function c1295111.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的连接怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 自己基本分回复那只怪兽的原本攻击力的数值。
		Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
