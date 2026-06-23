--転生炎獣パイロ・フェニックス
-- 效果：
-- 炎属性效果怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡用「转生炎兽 火凤凰」为素材作连接召唤成功的场合才能发动。对方场上的卡全部破坏。
-- ②：以对方墓地1只连接怪兽为对象才能发动。那只怪兽在对方场上特殊召唤。
-- ③：对方场上有连接怪兽特殊召唤的场合，以那1只怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c31313405.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用至少2个满足条件的卡片作为连接素材
	aux.AddLinkProcedure(c,c31313405.matfilter,2)
	-- ①：这张卡用「转生炎兽 火凤凰」为素材作连接召唤成功的场合才能发动。对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31313405,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c31313405.descon)
	e1:SetTarget(c31313405.destg)
	e1:SetOperation(c31313405.desop)
	c:RegisterEffect(e1)
	-- ②：以对方墓地1只连接怪兽为对象才能发动。那只怪兽在对方场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c31313405.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：对方场上有连接怪兽特殊召唤的场合，以那1只怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31313405,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31313405)
	e3:SetTarget(c31313405.sptg)
	e3:SetOperation(c31313405.spop)
	c:RegisterEffect(e3)
	-- 炎属性效果怪兽2只以上
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31313405,2))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,31313406)
	e4:SetTarget(c31313405.damtg)
	e4:SetOperation(c31313405.damop)
	c:RegisterEffect(e4)
end
-- 连接召唤素材必须是效果怪兽且属性为炎
function c31313405.matfilter(c)
	return c:IsLinkType(TYPE_EFFECT) and c:IsLinkAttribute(ATTRIBUTE_FIRE)
end
-- 检查连接召唤时是否使用了转生炎兽火凤凰作为素材
function c31313405.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,31313405) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为连接召唤且使用了转生炎兽火凤凰作为素材
function c31313405.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 设置破坏效果的目标为对方场上的所有卡
function c31313405.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：对方场上有卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将对方场上的所有卡破坏
function c31313405.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 执行破坏效果，将对方场上的所有卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 筛选可特殊召唤的连接怪兽
function c31313405.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 设置特殊召唤效果的目标为对方墓地的连接怪兽
function c31313405.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c31313405.spfilter(chkc,e,tp) end
	-- 判断是否满足发动条件：对方墓地有连接怪兽且对方场上还有空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 判断是否满足发动条件：对方墓地有连接怪兽
		and Duel.IsExistingTarget(c31313405.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地的一只连接怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c31313405.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁操作信息，指定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果，将选中的怪兽特殊召唤到对方场上
function c31313405.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行特殊召唤效果，将选中的怪兽特殊召唤到对方场上
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 筛选对方场上的连接怪兽
function c31313405.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_LINK) and c:GetBaseAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE)
end
-- 设置伤害效果的目标为对方场上特殊召唤的连接怪兽
function c31313405.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c31313405.cfilter(chkc,e,1-tp) end
	if chk==0 then return eg:IsExists(c31313405.cfilter,1,nil,e,1-tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c31313405.cfilter,1,1,nil,e,1-tp)
	-- 设置当前连锁的目标卡
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息，指定要造成伤害的数值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- 执行伤害效果，给与对方指定怪兽的攻击力数值的伤害
function c31313405.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行伤害效果，给与对方指定怪兽的攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
