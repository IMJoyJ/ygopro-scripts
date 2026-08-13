--リローダー・ドラゴン
-- 效果：
-- 「弹丸」怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以这张卡以外的自己场上1只连接怪兽为对象才能发动。从手卡把1只「弹丸」怪兽在作为那张卡所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽不能作为连接素材，结束阶段破坏。
-- ②：这张卡被战斗破坏送去墓地时，以自己墓地1只「弹丸」怪兽为对象才能发动。那只怪兽加入手卡。
function c15627227.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用2只「弹丸」怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x102),2,2)
	-- 「这个卡名的①的效果1回合只能使用1次。①：以这张卡以外的自己场上1只连接怪兽为对象才能发动。从手卡把1只『弹丸』怪兽在作为那张卡所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽不能作为连接素材，结束阶段破坏。」
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
	-- 「②：这张卡被战斗破坏送去墓地时，以自己墓地1只『弹丸』怪兽为对象才能发动。那只怪兽加入手卡。」
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
-- spfilter1是①效果可选取对象的过滤函数：对象必须表侧表示、是连接怪兽，并且手牌中存在能够特殊召唤到该连接怪兽所连接区的「弹丸」怪兽。
function c15627227.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
		-- 检查手牌中是否存在满足spfilter2的「弹丸」怪兽，并以该连接怪兽所连接区zone作为特殊召唤的目标区域。
		and Duel.IsExistingMatchingCard(c15627227.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetLinkedZone(tp))
end
-- spfilter2是手牌中「弹丸」怪兽的过滤函数：属于「弹丸」字段，且能够在本效果下以表侧表示特殊召唤到指定链接区zone。
function c15627227.spfilter2(c,e,tp,zone)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- sptg是①效果的发动时目标选择函数：进行效果发动的合法性检查、选择场上1只连接怪兽作为对象，并设置特殊召唤的操作信息。
function c15627227.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c15627227.spfilter1(chkc,e,tp) and chkc~=c end
	-- 在发动合法性检查中，确认自己场上存在1只满足spfilter1且不是这张卡本身的连接怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c15627227.spfilter1,tp,LOCATION_MZONE,0,1,c,e,tp) end
	-- 弹出提示消息，要求玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足spfilter1的连接怪兽作为效果对象，并自动与该连锁建立联系。
	Duel.SelectTarget(tp,c15627227.spfilter1,tp,LOCATION_MZONE,0,1,1,c,e,tp)
	-- 设置操作信息：本效果预定从手卡特殊召唤1只怪兽，目标玩家为tp，来源位置为手牌。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- spop是①效果处理时的操作函数：取出对象连接怪兽，确认其仍相关且表侧后，在对象所连接区特殊召唤1只手牌「弹丸」怪兽，并为其附加不能作为连接素材和结束阶段破坏的限制，最后完成特殊召唤。
function c15627227.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的对象连接怪兽。
	local lc=Duel.GetFirstTarget()
	if lc:IsRelateToEffect(e) and lc:IsFaceup() then
		local zone=lc:GetLinkedZone(tp)
		-- 检查对象怪兽所连接区是否有可用空格；若没有空位则本次特殊召唤不适用。
		if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
		-- 弹出提示消息，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1只满足spfilter2的「弹丸」怪兽，返回选择的第一张卡。
		local tc=Duel.SelectMatchingCard(tp,c15627227.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone):GetFirst()
		-- 若成功选择到怪兽并通过SpecialSummonStep完成特殊召唤步骤，则继续为其附加限制效果和结束阶段破坏标记。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone) then
			-- 「这个效果特殊召唤的怪兽不能作为连接素材，结束阶段破坏。」——为特殊召唤的怪兽赋予不能作为连接素材的效果，并用flag标记该怪兽以便结束阶段破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(15627227,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 「这个效果特殊召唤的怪兽不能作为连接素材，结束阶段破坏。」——创建并注册在结束阶段破坏该特殊召唤怪兽的持续效果，同时给出后续的破坏条件判断与处理函数。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetCountLimit(1)
			e2:SetLabel(fid)
			e2:SetLabelObject(tc)
			e2:SetCondition(c15627227.descon)
			e2:SetOperation(c15627227.desop)
			-- 将用于在结束阶段破坏特殊召唤怪兽的持续效果注册到场上，由tp玩家控制。
			Duel.RegisterEffect(e2,tp)
		end
		-- 完成整个特殊召唤处理，正式确定所有通过SpecialSummonStep的怪兽特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
end
-- descon是结束阶段破坏效果的发动条件：检查标记的怪兽仍存在且其flag标记值与效果中保存的fid一致，避免误破坏其他同名怪兽。
function c15627227.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(15627227)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- desop是结束阶段破坏效果的处理：将标记的那只特殊召唤怪兽破坏。
function c15627227.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行破坏操作，破坏原因为效果。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- thcon是②效果的发动条件：这张卡被战斗破坏并送去墓地时，且其此前控制者为tp，满足“被战斗破坏送去墓地”的触发条件。
function c15627227.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and bit.band(r,0x21)==0x21
end
-- thfilter是墓地中「弹丸」怪兽的过滤条件：是怪兽、属于「弹丸」字段、并且可以被加入手卡。
function c15627227.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x102) and c:IsAbleToHand()
end
-- thtg是②效果的目标选择函数：进行发动合法性检查、选择自己墓地1只「弹丸」怪兽作为对象，并设置回手牌的操作信息。
function c15627227.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15627227.thfilter(chkc) end
	-- 在发动合法性检查中，确认自己墓地存在1只满足thfilter的「弹丸」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c15627227.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示消息，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足thfilter的「弹丸」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c15627227.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本效果预定将1张卡加入手牌，对象为已选择的墓地怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- thop是②效果处理时的操作：获取对象怪兽并将其加入手牌。
function c15627227.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回其持有者的手牌，原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
