--超量士レッドレイヤー
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤时，以自己墓地1张「超级量子」卡为对象才能发动。那张卡加入手卡。
-- ③：这张卡被送去墓地的场合，以「超级量子战士 红光层」以外的自己墓地1只「超级量子」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能把效果发动。
function c59975920.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59975920,0))  --"这张卡从手卡特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c59975920.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤时，以自己墓地1张「超级量子」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59975920,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,59975920)
	e2:SetTarget(c59975920.thtg)
	e2:SetOperation(c59975920.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合，以「超级量子战士 红光层」以外的自己墓地1只「超级量子」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能把效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(59975920,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,59975921)
	e4:SetTarget(c59975920.sptg)
	e4:SetOperation(c59975920.spop)
	c:RegisterEffect(e4)
end
-- 手卡特殊召唤效果的自身特殊召唤规则的条件判定函数
function c59975920.spcon(e,c)
	if c==nil then return true end
	-- 判定自己场上是否存在怪兽（数量为0）
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判定自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤自己墓地中可加入手牌的「超级量子」卡的条件函数
function c59975920.thfilter(c)
	return c:IsSetCard(0xdc) and c:IsAbleToHand()
end
-- 回收墓地「超级量子」卡效果的发动准备与目标选择
function c59975920.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59975920.thfilter(chkc) end
	-- 在效果发动阶段，判定自己墓地是否存在符合条件的「超级量子」卡
	if chk==0 then return Duel.IsExistingTarget(c59975920.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的「超级量子」卡作为效果的对象
	local g=Duel.SelectTarget(tp,c59975920.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示该效果包含将选中的1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收墓地「超级量子」卡效果的效果处理函数
function c59975920.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果将目标卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可特殊召唤的「超级量子战士 红光层」以外的「超级量子」怪兽的条件函数
function c59975920.filter(c,e,tp)
	return c:IsSetCard(0xdc) and not c:IsCode(59975920) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤墓地「超级量子」怪兽效果的发动准备与目标选择
function c59975920.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59975920.filter(chkc,e,tp) end
	-- 在效果发动阶段，判定自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并判定自己墓地是否存在符合条件的「超级量子」怪兽
		and Duel.IsExistingTarget(c59975920.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「超级量子」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c59975920.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤选中的1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤墓地「超级量子」怪兽效果的效果处理函数
function c59975920.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	-- 若目标卡片仍与效果相关，则将其以表侧表示特殊召唤到场上（作为特殊召唤步骤的第一步）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(59975920,3))  --"「超级量子战士 红光层」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理，使怪兽正式登场并触发相关时点
	Duel.SpecialSummonComplete()
end
