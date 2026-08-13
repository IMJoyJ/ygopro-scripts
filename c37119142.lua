--コード・エクスポーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽加入手卡。场上的这张卡为素材的场合可以不加入手卡把效果无效特殊召唤。
function c37119142.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,37119142)
	e1:SetValue(c37119142.matval)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽加入手卡。场上的这张卡为素材的场合可以不加入手卡把效果无效特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37119142,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,37119143)
	e2:SetCondition(c37119142.thcon)
	e2:SetTarget(c37119142.thtg)
	e2:SetOperation(c37119142.thop)
	c:RegisterEffect(e2)
end
-- 筛选自己场上存在的电子界族怪兽（位于主要怪兽区、电子界族、控制者为己方），用于判断是否满足以自己场上的电子界族怪兽作为连接素材的条件。
function c37119142.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 筛选手卡中的这张代码导出员自身，用于素材组判定时排除重复加入这张卡。
function c37119142.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(37119142)
end
-- EFFECT_EXTRA_LINK_MATERIAL的值判定：目标连接怪兽为码语者怪兽时，若素材组中已有自己场上的电子界族怪兽且尚未包含手卡的这张自身卡，则允许这张手卡作为追加连接素材；素材组为空时直接允许。
function c37119142.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x101) then return false,nil end
	return true,not mg or mg:IsExists(c37119142.mfilter,1,nil,tp) and not mg:IsExists(c37119142.exmfilter,1,nil)
end
-- ②效果的发动条件：这张卡作为「码语者」怪兽的连接素材从手卡或场上被送去墓地，且当前在墓地、送去墓地原因为连接召唤时满足条件；若此前位于场上，则额外标记Label为1（表示可选择特殊召唤），并给自己附加一个‘从场上送去墓地’的提示标记。
function c37119142.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(0)
	if c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x101) then
		if c:IsPreviousLocation(LOCATION_ONFIELD) then
			e:SetLabel(1)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(37119142,1))  --"从场上送去墓地"
		end
		return true
	else
		return false
	end
end
-- 墓地对象筛选：选择自己墓地1只4星以下的电子界族怪兽，要求它能加入手卡；若chk为1（即本卡从场上作为素材），也可选择可特殊召唤的电子界族怪兽，但需要有可用怪兽区。
function c37119142.thfilter(c,e,tp,chk)
	return c:IsRace(RACE_CYBERSE) and c:IsLevelBelow(4)
		-- 候选条件：目标怪兽可以加入手卡，或者（从场上作为素材时）自己怪兽区有空位且该怪兽可以被特殊召唤。
		and (c:IsAbleToHand() or (chk==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ②效果发动时的目标选择：根据本卡作为素材时所在位置（手牌/场上）设置效果分类，从自己墓地选择1只符合条件的电子界族怪兽作为对象；若从场上作为素材，则效果分类同时包含加入手卡与特殊召唤。
function c37119142.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local check=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37119142.thfilter(chkc,e,tp,check) end
	-- 在效果发动时确认自己墓地是否存在至少1只符合条件的电子界族怪兽可取对象，若存在则发动合法。
	if chk==0 then return Duel.IsExistingTarget(c37119142.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,check) end
	-- 向操作玩家显示‘请选择要加入手牌的卡’的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的电子界族怪兽，将其设为效果对象。
	local g=Duel.SelectTarget(tp,c37119142.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	if e:GetLabel()==0 then
		e:SetCategory(CATEGORY_TOHAND)
		-- 设定操作信息：本效果会将对象卡加入手卡，数量为1（供其他卡进行效果发动检测）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	end
end
-- ②效果处理：获取对象卡，若对象仍关联本效果，则根据素材来源和玩家选择，要么将对象加入手卡，要么将其特殊召唤（若从场上作为素材时玩家选择特殊召唤且条件允许）；特殊召唤时使该怪兽效果无效化。
function c37119142.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁的效果对象：自己墓地中选择的那只电子界族怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsAbleToHand()
		-- 满足以下任一情况时执行加入手卡：效果标记为0（从手卡作为素材）、自己主要怪兽区无空位、对象不能特殊召唤、或玩家在选项中选择加入手卡；否则执行特殊召唤。
		and (e:GetLabel()==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1190,1152)==0) then
		-- 将对象怪兽送去其持有者的手卡，原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	else
		-- 以表侧攻击表示将对象怪兽特殊召唤到自己场上（特殊召唤步骤），若成功则继续给它附加无效化效果。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 结束特殊召唤步骤，完成特殊召唤处理（确认特殊召唤成功并处理召唤时点）。
		Duel.SpecialSummonComplete()
	end
end
