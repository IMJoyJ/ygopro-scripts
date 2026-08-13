--転生炎獣パイロ・フェニックス
-- 效果：
-- 炎属性效果怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡用「转生炎兽 火凤凰」为素材作连接召唤成功的场合才能发动。对方场上的卡全部破坏。
-- ②：以对方墓地1只连接怪兽为对象才能发动。那只怪兽在对方场上特殊召唤。
-- ③：对方场上有连接怪兽特殊召唤的场合，以那1只怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c31313405.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用2只以上满足matfilter条件的怪兽作为连接素材进行连接召唤。
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
	-- ①：这张卡用「转生炎兽 火凤凰」为素材作连接召唤成功的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c31313405.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：以对方墓地1只连接怪兽为对象才能发动。那只怪兽在对方场上特殊召唤。
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
	-- ③：对方场上有连接怪兽特殊召唤的场合，以那1只怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
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
-- 判定连接素材是否为效果怪兽且炎属性，以满足「炎属性效果怪兽2只以上」的召唤条件。
function c31313405.matfilter(c)
	return c:IsLinkType(TYPE_EFFECT) and c:IsLinkAttribute(ATTRIBUTE_FIRE)
end
-- 检查连接召唤使用的素材中是否存在卡名「转生炎兽 火凤凰」，并将结果标记到①效果上，用于①的发动条件判定。
function c31313405.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,31313405) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ①效果的发动条件：这张卡是连接召唤成功，且其素材中包含「转生炎兽 火凤凰」。
function c31313405.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- ①效果发动时：检测对方场上有卡，并将对方场上全部卡片设定为破坏对象。
function c31313405.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认对方场上存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上全部卡片。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次效果将破坏对方场上全部卡片，数量为那些卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理时：获取对方场上全部卡片并全部破坏。
function c31313405.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取对方场上所有卡片。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因将这些卡片破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 筛选对方墓地中满足条件的连接怪兽：是连接怪兽，且可以被我方效果特殊召唤到对方场上。
function c31313405.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- ②效果的发动条件和取对象处理：确认对方场上有空位且对方墓地存在可特殊召唤的连接怪兽，然后选择1只为对象。
function c31313405.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c31313405.spfilter(chkc,e,tp) end
	-- 发动条件之一：对方场上有可用的怪兽区，用于将怪兽特殊召唤到对方场上。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 发动条件之二：对方墓地存在满足特殊召唤条件的连接怪兽可供选择。
		and Duel.IsExistingTarget(c31313405.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地选择1只符合条件的连接怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c31313405.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将特殊召唤1只怪兽到对方场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理时：将对象怪兽以表侧表示特殊召唤到对方场上。
function c31313405.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果所选择的对方墓地那只连接怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到对方场上（由我方使对方场上特殊召唤）。
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 筛选刚特殊召唤到对方场上的连接怪兽：表侧表示、在对方怪兽区、连接怪兽、原本攻击力大于0、且能成为效果对象。
function c31313405.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_LINK) and c:GetBaseAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE)
end
-- ③效果的发动条件和对象选择：对方场上有连接怪兽特殊召唤时，选择那1只怪兽为对象，并设定造成其原本攻击力数值的伤害。
function c31313405.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c31313405.cfilter(chkc,e,1-tp) end
	if chk==0 then return eg:IsExists(c31313405.cfilter,1,nil,e,1-tp) end
	-- 显示“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c31313405.cfilter,1,1,nil,e,1-tp)
	-- 将选中的连接怪兽设为③效果的对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：对对方造成该怪兽原本攻击力数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- ③效果处理时：判定对象仍然有效后，给对方造成对象怪兽原本攻击力数值的伤害。
function c31313405.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果所选的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因给对方造成该怪兽原本攻击力数值的伤害。
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
