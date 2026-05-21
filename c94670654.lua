--獣の忍者－獏
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤·反转的场合，从自己墓地以及自己的魔法与陷阱区域的表侧表示的卡之中以「兽之忍者-貘」以外的1张「忍者」卡或者「忍法」卡为对象才能发动。那张卡回到持有者手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特召效果、特召成功时回收效果以及反转成功时回收效果。
function s.initial_effect(c)
	-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤·反转的场合，从自己墓地以及自己的魔法与陷阱区域的表侧表示的卡之中以「兽之忍者-貘」以外的1张「忍者」卡或者「忍法」卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
-- 判定这张卡加入手牌的原因是否为抽卡以外的方式。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- 特殊召唤效果的发动准备与合法性检测。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关联，则将此卡在自己场上表侧表示特殊召唤。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 过滤出自己墓地或魔法与陷阱区域表侧表示的、「兽之忍者-貘」以外的「忍者」卡或「忍法」卡，且该卡能回到手牌。
function s.filter(c)
	return c:IsSetCard(0x2b,0x61) and c:IsAbleToHand() and not c:IsCode(id)
		and (c:IsFaceup() and c:GetSequence()<5 or c:IsLocation(LOCATION_GRAVE))
end
-- 回收效果的发动准备、对象选择与合法性检测。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 判定自己墓地或魔法与陷阱区域是否存在符合条件的卡作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地或魔法与陷阱区域表侧表示的1张符合条件的卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理中的操作信息为将选中的对象卡送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的执行函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
