--終刻獄徒 ディアクトロス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。自己的手卡·场上（表侧表示）1张「终刻」卡破坏。那之后，可以把场上1只怪兽破坏。
-- ②：有「终刻」怪兽或「无垢者 米底乌斯」在作为超量素材中的这张卡被效果破坏的场合才能发动。从卡组选1张装备魔法卡加入手卡或送去墓地。
local s,id,o=GetID()
-- 初始化函数：为这张卡设置超量召唤条件（4星怪兽×2）、苏生限制，并注册①效果（特殊召唤时破坏「终刻」卡，可选追加破坏场上怪兽）和②效果（被效果破坏且持有对应素材时检索/送墓装备魔法卡），两个效果均1回合1次。
function s.initial_effect(c)
	-- 将卡号97556336（无垢者 米底乌斯）添加到这张卡的记载卡名列表中，用于②效果对超量素材的判定。
	aux.AddCodeList(c,97556336)
	-- 为这张卡添加超量召唤手续：以4星怪兽2只为素材进行超量召唤（对应效果文本中的“4星怪兽×2”）。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤的场合才能发动。自己的手卡·场上（表侧表示）1张「终刻」卡破坏。那之后，可以把场上1只怪兽破坏。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：有「终刻」怪兽或「无垢者 米底乌斯」在作为超量素材中的这张卡被效果破坏的场合才能发动。从卡组选1张装备魔法卡加入手卡或送去墓地。
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
-- 定义①效果的破坏对象过滤器：选择手卡或场上表侧表示的「终刻」卡（IsFaceupEx对手卡视为表侧，场上的卡需表侧表示）。
function s.desfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1d2)
end
-- ①效果的发动条件和目标设定：检查自己手卡·场上是否存在可选的「终刻」卡；存在则设置破坏信息，并向对方提示发动了此效果。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·场上所有可作为①效果破坏对象的「终刻」卡。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	if chk==0 then return #g>0 end
	-- 将本次连锁的操作信息登记为「破坏」，候选对象为这些「终刻」卡，预定数量为1，供其他效果（如星尘龙等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 向对方玩家提示：我方发动了这张卡的①效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①效果的处理：先从自己的手卡·场上选择1张「终刻」卡破坏；若破坏成功且双方场上有怪兽，则询问是否再破坏场上1只怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示“请选择要破坏的卡”的提示，让己方进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己的手卡·场上选择1张符合条件的「终刻」卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	local fg=g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
	if fg:GetCount()>0 then
		-- 对被选中的场上卡片显示选中动画，并记录这些卡被选中为对象（手卡中的卡不显示）。
		Duel.HintSelection(fg)
	end
	-- 用效果破坏所选的「终刻」卡，并判断是否实际破坏成功。
	if Duel.Destroy(g,REASON_EFFECT)>0
		-- 检查双方场上是否存在至少1只怪兽，作为追加破坏的候选。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 询问己方玩家是否要追加破坏场上1只怪兽（对应“那之后，可以把场上1只怪兽破坏”）。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把场上怪兽破坏？"
		-- 中断当前效果处理，使后续的追加破坏在时点上与前半段效果分离，避免被视作同时处理。
		Duel.BreakEffect()
		-- 再次显示“请选择要破坏的卡”的提示，用于选择追加破坏的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从双方场上选择1只怪兽作为追加破坏对象。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 为选中的追加破坏对象显示选中动画。
			Duel.HintSelection(g)
			-- 用效果破坏所选的怪兽。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 定义超量素材的判定条件：（素材是「终刻」怪兽）或（素材是「无垢者 米底乌斯」）。
function s.cfilter(c)
	return c:IsSetCard(0x1d2) and c:IsType(TYPE_MONSTER) or c:IsCode(97556336)
end
-- ②效果的发动条件：这张卡被效果破坏，且破坏前在怪兽区，并且其超量素材中存在「终刻」怪兽或「无垢者 米底乌斯」。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
		and g:IsExists(s.cfilter,1,nil)
end
-- 定义②效果的检索对象过滤器：装备魔法卡，且可以加入手卡或送去墓地。
function s.thfilter(c)
	return c:IsType(TYPE_EQUIP)
		and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ②效果的目标设定：判断卡组中是否存在至少1张符合条件的装备魔法卡，决定能否发动。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组中是否有1张以上符合条件的装备魔法卡（发动条件判定）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的处理：从卡组选择1张装备魔法卡，根据玩家选择将其加入手卡或送去墓地。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要操作的卡”的提示，让己方从卡组选择装备魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1张符合条件的装备魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 如果该卡能够加入手卡，并且（它不能送去墓地，或者玩家在选项中选择“加入手卡”），则执行加入手卡分支。
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的装备魔法卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认这张从卡组加入手卡的装备魔法卡。
		Duel.ConfirmCards(1-tp,tc)
	elseif tc:IsAbleToGrave() then
		-- 若未选择加入手卡，且该卡能送去墓地，则将其用效果送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
