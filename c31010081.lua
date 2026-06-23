--終刻獄徒 ディアクトロス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。自己的手卡·场上（表侧表示）1张「终刻」卡破坏。那之后，可以把场上1只怪兽破坏。
-- ②：有「终刻」怪兽或「无垢者 米底乌斯」在作为超量素材中的这张卡被效果破坏的场合才能发动。从卡组选1张装备魔法卡加入手卡或送去墓地。
local s,id,o=GetID()
-- 初始化效果，注册XYZ召唤手续并设置复活限制，创建①②效果
function s.initial_effect(c)
	-- 记录该卡拥有「无垢者 米底乌斯」的卡名
	aux.AddCodeList(c,97556336)
	-- 设置该卡为4星、2叠放的XYZ怪兽
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。自己的手卡·场上（表侧表示）1张「终刻」卡破坏。那之后，可以把场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：有「终刻」怪兽或「无垢者 米底乌斯」在作为超量素材中的这张卡被效果破坏的场合才能发动。从卡组选1张装备魔法卡加入手卡或送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选表侧表示的「终刻」卡
function s.desfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1d2)
end
-- ①效果的发动时处理函数，检索满足条件的「终刻」卡并设置破坏目标
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的「终刻」卡
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	if chk==0 then return #g>0 end
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①效果的处理函数，选择并破坏「终刻」卡，若满足条件则再破坏场上怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的「终刻」卡
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	local fg=g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
	if fg:GetCount()>0 then
		-- 显示被选为对象的卡
		Duel.HintSelection(fg)
	end
	-- 破坏选中的卡
	if Duel.Destroy(g,REASON_EFFECT)>0
		-- 检查场上是否存在怪兽
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 询问玩家是否破坏场上怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把场上怪兽破坏？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上怪兽进行破坏
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 显示被选为对象的卡
			Duel.HintSelection(g)
			-- 破坏选中的怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于筛选超量素材中的「终刻」怪兽或「无垢者 米底乌斯」
function s.cfilter(c)
	return c:IsSetCard(0x1d2) and c:IsType(TYPE_MONSTER) or c:IsCode(97556336)
end
-- ②效果的发动条件函数，判断是否满足发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
		and g:IsExists(s.cfilter,1,nil)
end
-- 过滤函数，用于筛选装备魔法卡
function s.thfilter(c)
	return c:IsType(TYPE_EQUIP)
		and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ②效果的发动时处理函数，检索满足条件的装备魔法卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的处理函数，选择装备魔法卡并将其加入手卡或送去墓地
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择满足条件的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断是否将装备魔法卡加入手卡
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将装备魔法卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方玩家看到该卡
		Duel.ConfirmCards(1-tp,tc)
	elseif tc:IsAbleToGrave() then
		-- 将装备魔法卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
