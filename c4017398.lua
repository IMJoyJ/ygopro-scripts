--ゼアル・エントラスト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地的「希望皇 霍普」、「异热同心武器」、「异热同心从者」怪兽之内任意1只为对象才能发动。那只怪兽加入手卡或特殊召唤。
-- ②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外，以「异热同心信托」以外的自己墓地1张「异热同心」魔法·陷阱卡为对象才能发动。那张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c4017398.initial_effect(c)
	-- ①：以自己墓地的「希望皇 霍普」、「异热同心武器」、「异热同心从者」怪兽之内任意1只为对象才能发动。那只怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,4017398)
	e1:SetTarget(c4017398.target)
	e1:SetOperation(c4017398.activate)
	c:RegisterEffect(e1)
	-- ②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外，以「异热同心信托」以外的自己墓地1张「异热同心」魔法·陷阱卡为对象才能发动。那张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4017398,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,4017399)
	-- 设置②效果的发动代价为把墓地的这张卡除外（aux.bfgcost负责判定并执行除外自身作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c4017398.thcon)
	e2:SetTarget(c4017398.thtg)
	e2:SetOperation(c4017398.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果选择对象的过滤函数：必须属于「希望皇 霍普」、「异热同心武器」、「异热同心从者」其中之一，且是怪兽，并且满足“能加入手卡”或“能特殊召唤”中的至少一项。
function c4017398.spfilter(c,e,tp)
	return c:IsSetCard(0x107f,0x107e,0x207e) and c:IsType(TYPE_MONSTER)
		-- 对象怪兽必须满足：可以加入手卡，或者自己主要怪兽区有空位且该怪兽能被效果特殊召唤；以此对应①效果“加入手卡或特殊召唤”的选择。
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的发动target：进行取对象判定，若满足条件则从自己墓地选择1只符合条件的怪兽作为效果对象。
function c4017398.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4017398.spfilter(chkc,e,tp) end
	-- 发动时（chk==0）检查自己墓地是否存在至少1只满足spfilter条件的怪兽并能成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c4017398.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给当前玩家显示“请选择效果的对象”的消息提示，用于选择卡片时的提示文本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1只满足spfilter条件的怪兽作为效果对象，并自动将该卡与当前连锁建立对象联系。
	local g=Duel.SelectTarget(tp,c4017398.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
-- ①效果处理时的操作：取得对象卡，若对象仍与效果关联且未被王家长眠之谷等无效，则根据玩家选择将对象特殊召唤或加入手卡。
function c4017398.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时选择的对象卡（此效果只取1张，所以直接取第1张目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查对象卡是否受王家长眠之谷等效果影响，若适用则无效当前连锁效果并停止后续处理。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 判断自己主要怪兽区是否还有可用空格，并且对象怪兽能否被当前效果特殊召唤（检查召唤条件和苏生限制）。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若对象不能加入手卡则直接选择特殊召唤；若能加入手卡，则弹窗让玩家在“特殊召唤/加入手卡”中选择，选择特殊召唤（序号1）时执行特召，否则执行回手。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将对象怪兽加入其持有者的手卡，处理原因为效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件判定：自己LP比对方少2000以上，且满足“这张卡送去墓地的回合不能发动”的限制。
function c4017398.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己LP是否不高于对方LP减去2000，并且通过aux.exccon排除这张卡本回合送去墓地的情况。
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000 and aux.exccon(e)
end
-- ②效果选择对象的过滤条件：是「异热同心」字段的魔法·陷阱卡，不是本卡（异热同心信托），且可以加入手卡。
function c4017398.thfilter(c)
	return c:IsSetCard(0x7e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(4017398) and c:IsAbleToHand()
end
-- ②效果的发动target：从自己墓地选择1张符合条件的「异热同心」魔法·陷阱卡作为对象，并设置操作信息为回手。
function c4017398.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4017398.thfilter(chkc) end
	-- 发动时检查自己墓地是否存在至少1张满足thfilter条件的卡片并能成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c4017398.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给当前玩家显示“请选择要加入手牌的卡”的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足thfilter条件的卡作为效果对象，并建立对象关联。
	local g=Duel.SelectTarget(tp,c4017398.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，标明本效果将把1张卡加入手卡，供相关卡牌效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理时的操作：取得对象卡，若对象仍与效果关联，则将其加入持有者手卡。
function c4017398.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象卡（此效果只取1张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
