--ライゼオル・デュオドライブ
-- 效果：
-- 4星怪兽×2只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。把自己墓地1只「雷火沸动」怪兽作为这张卡的超量素材。
-- ②：让自己场上的怪兽的攻击力上升并让对方场上的怪兽的攻击力下降这张卡的超量素材数量×100。
-- ③：自己主要阶段才能发动。自己场上2个超量素材取除，从卡组把2张「雷火沸动」卡加入手卡（同名卡最多1张）。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含超量召唤手续、特殊召唤成功时将墓地怪兽叠放为素材的效果、增减双方场上怪兽攻击力的效果，以及主要阶段检索卡组卡片的效果。
function s.initial_effect(c)
	-- 添加超量召唤手续：4星怪兽2只以上。
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。把自己墓地1只「雷火沸动」怪兽作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获取超量素材"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	-- ②：让自己场上的怪兽的攻击力上升并让对方场上的怪兽的攻击力下降这张卡的超量素材数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.val1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(s.val2)
	c:RegisterEffect(e3)
	-- ③：自己主要阶段才能发动。自己场上2个超量素材取除，从卡组把2张「雷火沸动」卡加入手卡（同名卡最多1张）。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 过滤墓地中满足条件的「雷火沸动」怪兽，且该怪兽可以作为超量素材且不受当前效果影响。
function s.mtfilter(c,e)
	return c:IsSetCard(0x1be) and c:IsType(TYPE_MONSTER)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果①的发动条件与对象检查：这张卡是超量怪兽，且自己墓地存在至少1只满足条件的「雷火沸动」怪兽。
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己墓地是否存在至少1张满足条件的「雷火沸动」怪兽。
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示发动了该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示此效果涉及将1张卡移出墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
end
-- 效果①的处理：将自己墓地1只「雷火沸动」怪兽作为这张卡的超量素材。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从自己墓地选择1张满足条件且不受「王家长眠之谷」影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
	if g:GetCount()>0 then
		-- 将选择的卡作为这张卡的超量素材重叠。
		Duel.Overlay(c,g)
	end
end
-- 计算自己场上怪兽攻击力上升的数值：这张卡的超量素材数量×100。
function s.val1(e,c)
	return e:GetHandler():GetOverlayCount()*100
end
-- 计算对方场上怪兽攻击力下降的数值：这张卡的超量素材数量×(-100)。
function s.val2(e,c)
	return e:GetHandler():GetOverlayCount()*(-100)
end
-- 过滤卡组中可以加入手牌的「雷火沸动」卡。
function s.thfilter(c)
	return c:IsSetCard(0x1be) and c:IsAbleToHand()
end
-- 效果③的发动条件与对象检查：自己场上能取除至少2个超量素材，且卡组中存在至少2种不同卡名的「雷火沸动」卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组中所有满足条件的「雷火沸动」卡。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 检查自己场上是否能以效果原因取除2个超量素材。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_EFFECT)
		and g:GetClassCount(Card.GetCode)>=2 end
	-- 向对方玩家提示发动了该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示此效果会从卡组将2张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果③的处理：取除自己场上2个超量素材，从卡组把2张卡名不同的「雷火沸动」卡加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的「雷火沸动」卡。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 尝试从自己场上取除2个超量素材，并检查是否成功。
	if Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_EFFECT)~=0
		and g:GetClassCount(Card.GetCode)>=2 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择2张卡名不同的「雷火沸动」卡。
		local tg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		if tg:GetCount()>0 then
			-- 将选择的卡加入手牌。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡。
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
