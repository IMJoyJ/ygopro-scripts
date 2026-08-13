--DDスケール・サーベイヤー
-- 效果：
-- ←9 【灵摆】 9→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己·对方的准备阶段，以自己·对方的灵摆区域最多2张卡为对象才能发动。那些卡的灵摆刻度直到回合结束时变成0。
-- 【怪兽效果】
-- 这个卡名的①②③的怪兽效果1回合各能使用1次。
-- ①：自己场上有「DD」灵摆怪兽卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。这张卡的等级变成4星。
-- ③：这张卡被送去墓地的场合或者表侧加入额外卡组的场合，以自己场上1张「DD」灵摆怪兽卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化函数：为这张卡启用灵摆属性，并注册以下效果：灵摆区域的准备阶段改变刻度、手牌特殊召唤、召唤·特殊召唤时变4星、被送去墓地或表侧加入额外卡组时回收「DD」灵摆怪兽回手；各效果均带同名卡1回合1次限制。
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽通用的灵摆召唤与灵摆卡发动能力。
	aux.EnablePendulumAttribute(c)
	-- 对应灵摆效果：这个卡名的灵摆效果1回合只能使用1次。①：自己·对方的准备阶段，以自己·对方的灵摆区域最多2张卡为对象才能发动。那些卡的灵摆刻度直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"改变刻度"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	-- 对应怪兽效果①：这个卡名的①②③的怪兽效果1回合各能使用1次。①：自己场上有「DD」灵摆怪兽卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 对应怪兽效果②：这个卡名的①②③的怪兽效果1回合各能使用1次。②：这张卡召唤·特殊召唤的场合才能发动。这张卡的等级变成4星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"改变等级"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- 对应怪兽效果③：这个卡名的①②③的怪兽效果1回合各能使用1次。③：这张卡被送去墓地的场合或者表侧加入额外卡组的场合，以自己场上1张「DD」灵摆怪兽卡为对象才能发动。那张卡回到手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))  --"回到手卡"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id+o*3)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_TO_DECK)
	e6:SetCondition(s.thcon)
	c:RegisterEffect(e6)
end
-- 过滤函数：用于筛选灵摆区域的卡，要求其左刻度不为0。
function s.scfilter(c)
	return c:GetLeftScale()~=0
end
-- 灵摆效果的目标函数：处理发动时点合法性、选择对象；从双方灵摆区域选择1~2张左刻度非0的卡作为对象。
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and s.scfilter(chkc) end
	-- 发动合法性检测：确认双方灵摆区域至少存在1张左刻度不为0的卡，满足条件才可发动。
	if chk==0 then return Duel.IsExistingTarget(s.scfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 向玩家显示选择对象的提示信息，对应“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从双方灵摆区域选择1~2张左刻度不为0的卡作为效果对象并登记为连锁对象。
	Duel.SelectTarget(tp,s.scfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,2,nil)
end
-- 灵摆效果处理：取出连锁对象，过滤出仍与效果相关的卡，对每张卡分别赋予将左刻度和右刻度改为0的持续效果，直到回合结束且该效果不能被无效。
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 遍历对象卡组中的每一张卡依次进行处理。
	for tc in aux.Next(tg) do
		-- 对应“那些卡的灵摆刻度直到回合结束时变成0”（本段实现左刻度的变更）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(0)
		tc:RegisterEffect(e2)
	end
end
-- 过滤条件：表侧表示、属于「DD」字段、原种类包含灵摆怪兽，用于判断场上是否存在「DD」灵摆怪兽卡。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 特殊召唤效果的条件：自己场上有满足过滤条件的「DD」灵摆怪兽卡存在时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「DD」灵摆怪兽卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果的目标函数：确认怪兽区域有空位且这张卡可以被特殊召唤时，效果才可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认我方怪兽区域存在可用的空格，供这张卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果为特殊召唤这张卡，数量1，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理：若这张卡仍与效果相关，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其持有者的场上（从手牌特殊召唤）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 改变等级效果的目标函数：仅当这张卡当前等级不是4时，效果才能发动。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return not c:IsLevel(4) end
end
-- 改变等级效果处理：若这张卡仍与效果相关、表侧表示且等级不是4，则赋予它将等级变为4的持续效果，离场或效果被无效时重置。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsLevel(4) then
		-- 对应“这张卡的等级变成4星”。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 表侧加入额外卡组场合的条件：这张卡当前位于额外卡组且是表侧表示。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
-- 回手效果的对象过滤：对象必须表侧表示、属于「DD」字段、原种类为灵摆怪兽，并且可以被加入手卡。
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsFaceup() and c:IsSetCard(0xaf)
		and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 回手效果的目标函数：在墓地或表侧加入额外卡组的场合，从自己场上选择1张符合条件的「DD」灵摆怪兽卡作为对象，并设置回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 效果发动合法性检测：确认自己场上存在至少1张符合条件的「DD」灵摆怪兽卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家显示选择提示“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1张符合条件的「DD」灵摆怪兽卡作为效果对象并登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：本次效果会把对象卡返回手牌（CATEGORY_TOHAND），数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回手效果处理：获取对象卡，若其仍与效果相关，则将其返回持有者手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中登记的第一张（也是唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送去持有者的手卡，即返回手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
