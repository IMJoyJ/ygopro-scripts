--リローダー・ドラゴン
-- 效果：
-- 「弹丸」怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以这张卡以外的自己场上1只连接怪兽为对象才能发动。从手卡把1只「弹丸」怪兽在作为那张卡所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽不能作为连接素材，结束阶段破坏。
-- ②：这张卡被战斗破坏送去墓地时，以自己墓地1只「弹丸」怪兽为对象才能发动。那只怪兽加入手卡。
function c15627227.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要2只满足「弹丸」卡族的连接怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x102),2,2)
	-- ①：以这张卡以外的自己场上1只连接怪兽为对象才能发动。从手卡把1只「弹丸」怪兽在作为那张卡所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽不能作为连接素材，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15627227,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,15627227)
	e1:SetTarget(c15627227.sptg)
	e1:SetOperation(c15627227.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时，以自己墓地1只「弹丸」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15627227,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c15627227.thcon)
	e2:SetTarget(c15627227.thtg)
	e2:SetOperation(c15627227.thop)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的连接怪兽，必须是表侧表示且存在可特殊召唤的「弹丸」怪兽
function c15627227.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
		-- 检查手牌中是否存在满足条件的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c15627227.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetLinkedZone(tp))
end
-- 筛选满足条件的「弹丸」怪兽，必须能特殊召唤到指定区域
function c15627227.spfilter2(c,e,tp,zone)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置效果目标，选择满足条件的连接怪兽
function c15627227.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c15627227.spfilter1(chkc,e,tp) and chkc~=c end
	-- 检查是否存在满足条件的连接怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c15627227.spfilter1,tp,LOCATION_MZONE,0,1,c,e,tp) end
	-- 提示玩家选择表侧表示的连接怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的连接怪兽作为目标
	Duel.SelectTarget(tp,c15627227.spfilter1,tp,LOCATION_MZONE,0,1,1,c,e,tp)
	-- 设置效果操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理效果的发动，特殊召唤满足条件的「弹丸」怪兽
function c15627227.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local lc=Duel.GetFirstTarget()
	if lc:IsRelateToEffect(e) and lc:IsFaceup() then
		local zone=lc:GetLinkedZone(tp)
		-- 检查目标怪兽的连接区域是否有足够的空间
		if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
		-- 提示玩家选择要特殊召唤的「弹丸」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的「弹丸」怪兽进行特殊召唤
		local tc=Duel.SelectMatchingCard(tp,c15627227.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone):GetFirst()
		-- 执行特殊召唤操作
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone) then
			-- 设置特殊召唤怪兽不能作为连接素材的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(15627227,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 设置特殊召唤怪兽在结束阶段被破坏的效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetCountLimit(1)
			e2:SetLabel(fid)
			e2:SetLabelObject(tc)
			e2:SetCondition(c15627227.descon)
			e2:SetOperation(c15627227.desop)
			-- 注册结束阶段破坏效果
			Duel.RegisterEffect(e2,tp)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 判断是否为同一场对战中特殊召唤的怪兽
function c15627227.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(15627227)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行破坏操作
function c15627227.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- 判断是否为被战斗破坏并送入墓地
function c15627227.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and bit.band(r,0x21)==0x21
end
-- 筛选满足条件的「弹丸」怪兽
function c15627227.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x102) and c:IsAbleToHand()
end
-- 设置效果目标，选择满足条件的墓地怪兽
function c15627227.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15627227.thfilter(chkc) end
	-- 检查是否存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c15627227.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectTarget(tp,c15627227.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，表示将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽加入手牌
function c15627227.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
