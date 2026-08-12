--オルターガイスト・アドミニア
-- 效果：
-- 「幻变骚灵」怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「幻变骚灵」陷阱卡在自己场上盖放。
-- ②：只在这张卡表侧表示存在才有1次，自己·对方的主要阶段，把自己场上1张卡送去墓地，以对方场上1只效果怪兽为对象才能发动。得到那只效果怪兽的控制权。那只怪兽也当作「幻变骚灵」怪兽使用。
local s,id,o=GetID()
-- 注册卡片效果：设置连接召唤手续，注册效果①（连接召唤成功时从卡组盖放「幻变骚灵」陷阱卡）和效果②（主要阶段送墓场上一张卡夺取对方效果怪兽控制权并当作「幻变骚灵」使用）。
function s.initial_effect(c)
	-- 设置连接召唤手续：需要2只以上的「幻变骚灵」怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x103),2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「幻变骚灵」陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：只在这张卡表侧表示存在才有1次，自己·对方的主要阶段，把自己场上1张卡送去墓地，以对方场上1只效果怪兽为对象才能发动。得到那只效果怪兽的控制权。那只怪兽也当作「幻变骚灵」怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.cost)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 效果①发动条件判定：这张卡是连接召唤成功的场合。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：检索卡组中属于「幻变骚灵」且可以盖放的陷阱卡。
function s.setfilter(c)
	return c:IsSetCard(0x103) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果①发动准备与合法性检测：检查卡组中是否存在可以盖放的「幻变骚灵」陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「幻变骚灵」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①处理：从卡组选择1张「幻变骚灵」陷阱卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「幻变骚灵」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片在自己场上盖放。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤函数：用于作为发动Cost送去墓地的卡，且该卡送去墓地后必须能空出足够的怪兽区域以容纳夺取控制权的怪兽。
function s.costfilter(c,tp)
	-- 检查卡片是否能作为Cost送去墓地，且该卡离开场后是否能提供用于获得控制权的怪兽区域。
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 效果②发动Cost处理：检查并选择自己场上1张卡送去墓地。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以作为Cost送去墓地且满足怪兽区域要求的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张满足Cost条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选择的卡作为发动Cost送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②发动条件判定：自己或对方的主要阶段。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤函数：对方场上表侧表示、可以改变控制权的效果怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler() and c:IsType(TYPE_EFFECT)
end
-- 效果②发动准备与对象选择：选择对方场上1只表侧表示的效果怪兽为对象，并设置控制权转移的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.filter(chkc) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的表侧表示效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要夺取控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家选择对方场上1只满足过滤条件的效果怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此效果包含夺取1只怪兽控制权的处理。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果②处理：尝试获得对象怪兽的控制权，若成功，则为其添加当作「幻变骚灵」怪兽使用的效果。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用此效果、是否表侧表示、是否为效果怪兽，并尝试获得其控制权。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT) and Duel.GetControl(tc,tp)~=0 then
		-- 那只怪兽也当作「幻变骚灵」怪兽使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
		e1:SetValue(0x103)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
