--音響戦士ギタリス
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以这张卡以外的自己场上1张「音响战士」卡为对象才能发动。那张卡和这张卡回到持有者手卡。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己的场地区域有「音响放大器」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
local s,id,o=GetID()
-- 初始化该卡的效果注册：登记卡名音响放大器、赋予灵摆属性，并依次注册灵摆回手效果（e1）、手卡特殊召唤效果（e2）以及召唤/特殊召唤成功时回手效果（e3/e4）。
function c43210483.initial_effect(c)
	-- 将75304793（音响放大器）登记为这张卡上记载的卡名，用于相关规则判定。
	aux.AddCodeList(c,75304793)
	-- 为这张卡赋予灵摆怪兽属性，使其能够作为灵摆卡发动并参与灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 【灵摆效果】这个卡名的灵摆效果1回合只能使用1次。①：以这张卡以外的自己场上1张「音响战士」卡为对象才能发动。那张卡和这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43210483,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,43210483)
	e1:SetTarget(c43210483.ptg)
	e1:SetOperation(c43210483.pop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】这个卡名的①②的怪兽效果1回合各能使用1次。①：自己的场地区域有「音响放大器」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43210483,1))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,43210483+o)
	e2:SetCondition(c43210483.spcon)
	e2:SetTarget(c43210483.sptg)
	e2:SetOperation(c43210483.spop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】这个卡名的①②的怪兽效果1回合各能使用1次。②：这张卡召唤·特殊召唤成功的场合，以自己的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43210483,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,43210483+o*2)
	e3:SetTarget(c43210483.thtg)
	e3:SetOperation(c43210483.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 定义筛选条件：卡片必须属于「音响战士」字段、表侧表示，并且可以被效果加入手卡。
function c43210483.pfilter(c)
	return c:IsSetCard(0x1066) and c:IsFaceup() and c:IsAbleToHand()
end
-- 发动时的取对象处理：检查玩家指定的对象是否为这张卡以外的自己场上满足条件的「音响战士」卡，并确认这张卡自身也可回手牌、场上存在合法对象。
function c43210483.ptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c and c43210483.pfilter(chkc) end
	if chk==0 then return c:IsAbleToHand()
		-- 检查自己场上是否存在1张除这张卡以外、满足「音响战士」字段且可回手牌的卡，并且该卡能成为效果对象。
		and Duel.IsExistingTarget(c43210483.pfilter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 弹出选择卡片提示，提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上选择1张满足条件的「音响战士」卡作为效果对象，并将其与当前连锁关联。
	local g=Duel.SelectTarget(tp,c43210483.pfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	g:AddCard(c)
	-- 设置操作信息：本次效果处理预计将2张卡（对象卡和这张卡）返回持有者手卡，供后续效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理：同时取回对象卡和这张卡，若二者仍与效果关联则将它们返回持有者手卡。
function c43210483.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的那张「音响战士」对象卡。
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 将对象卡和这张卡以效果原因返回持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 定义手卡特殊召唤效果的发动条件：自己的场地区域存在「音响放大器」。
function c43210483.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以tp的场地区域为判定范围时，当前生效的场地魔法是否为卡号75304793（音响放大器）。
	return Duel.IsEnvironment(75304793,tp,LOCATION_FZONE)
end
-- 手卡特殊召唤效果的发动判定：需要自己主要怪兽区有空位，且这张卡在手牌能够正常特殊召唤。
function c43210483.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位，以允许后续进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理将进行1次特殊召唤，对象为这张卡本身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果①的解决：若这张卡仍与效果关联，则将其从手卡以表侧攻击表示特殊召唤到自己场上。
function c43210483.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义召唤成功时诱发效果的发动条件与取对象：需要自己灵摆区域存在1张可回手牌的卡，并选择该卡作为对象。
function c43210483.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查自己灵摆区域是否存在至少1张可以被效果加入手卡的卡，作为效果发动的前提。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil) end
	-- 弹出选择卡片提示，提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己的灵摆区域选择1张可回手牌的卡作为效果对象，并将其与当前连锁关联。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,1,nil)
	-- 设置操作信息：本次效果处理预计将1张卡（对象卡）返回持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 怪兽效果②的解决：若对象卡仍与效果关联，则将其返回持有者手卡。
function c43210483.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那张灵摆区域对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因返回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
