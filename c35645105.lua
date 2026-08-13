--無限起動ハーヴェスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「无限起动 收割机」以外的1只「无限起动」怪兽加入手卡。
-- ②：以这张卡以外的自己场上1只机械族怪兽为对象才能发动。那只怪兽和这张卡直到回合结束时变成那2只的原本等级合计的等级。
function c35645105.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「无限起动 收割机」以外的1只「无限起动」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35645105,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,35645105)
	e1:SetTarget(c35645105.thtg)
	e1:SetOperation(c35645105.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的自己场上1只机械族怪兽为对象才能发动。那只怪兽和这张卡直到回合结束时变成那2只的原本等级合计的等级。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35645105,1))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,35645106)
	e3:SetTarget(c35645105.lvtg)
	e3:SetOperation(c35645105.lvop)
	c:RegisterEffect(e3)
end
-- 过滤检索目标：满足是「无限起动」怪兽、可为怪兽卡、可加入手卡，且卡名不是「无限起动 收割机」本身。
function c35645105.thfilter(c)
	return c:IsSetCard(0x127) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(35645105)
end
-- 效果①的发动条件和操作信息设定：确认卡组存在检索目标，并宣告本次效果将进行“从卡组将卡加入手卡”的处理。
function c35645105.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：己方卡组中必须存在至少1张满足检索条件的「无限起动」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c35645105.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将要把1张卡从卡组加入手卡，供连锁判定等规则使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：提示玩家选择，从卡组选1张符合条件的「无限起动」怪兽加入手卡，并展示给对方确认。
function c35645105.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组选择1张满足thfilter条件的卡（即符合检索要求的「无限起动」怪兽）。
	local g=Duel.SelectMatchingCard(tp,c35645105.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的对象过滤条件：表侧表示、机械族怪兽且等级大于等于0（即等级怪兽）。
function c35645105.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelAbove(0)
end
-- 效果②的发动条件与取对象：以自己场上除自身以外的1只表侧机械族怪兽为对象，并检查是否存在合法对象。
function c35645105.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc~=c and chkc:IsLocation(LOCATION_MZONE) and c35645105.lvfilter(chkc) end
	-- 发动合法性检查（chk==0）：自己场上是否存在除自身以外的1只满足条件的表侧机械族怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c35645105.lvfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 弹出选择提示：“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只除自身以外的表侧机械族怪兽作为效果对象，并将其与当前效果关联。
	Duel.SelectTarget(tp,c35645105.lvfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 效果②处理：若本卡和对象怪兽仍在场上表侧表示且与效果关联，则计算二者原本等级之和，并让双方等级都变为该数值直到回合结束。
function c35645105.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时选择的对方（对象）怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=c:GetOriginalLevel()+tc:GetOriginalLevel()
		c35645105.setlv(c,c,lv)
		c35645105.setlv(c,tc,lv)
	end
end
-- 创建一个不会无效的等级变更效果：使指定怪兽的等级变为lv，持续到回合结束，离场/回卡组等标准重置条件时重置。
function c35645105.setlv(c,ec,lv)
	-- 那只怪兽和这张卡直到回合结束时变成那2只的原本等级合计的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(lv)
	ec:RegisterEffect(e1)
end
