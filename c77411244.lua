--B－バスター・ドレイク
-- 效果：
-- ①：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只机械族·光属性怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
-- ②：装备怪兽不受对方的魔法卡的效果影响。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只同盟怪兽加入手卡。
function c77411244.initial_effect(c)
	-- 使用系统辅助函数，为卡片注册同盟怪兽的标准效果（包括装备、代替破坏、特殊召唤等）。
	aux.EnableUnionAttribute(c,c77411244.filter)
	-- ②：装备怪兽不受对方的魔法卡的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c77411244.efilter)
	c:RegisterEffect(e4)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只同盟怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c77411244.thcon)
	e5:SetTarget(c77411244.thtg)
	e5:SetOperation(c77411244.thop)
	c:RegisterEffect(e5)
end
c77411244.has_text_type=TYPE_UNION
-- 过滤条件：自己场上的机械族·光属性怪兽（同盟装备对象）。
function c77411244.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 免疫效果过滤器：对方玩家拥有的、且不是装备卡自身拥有的魔法卡效果。
function c77411244.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetOwner()~=e:GetOwner()
		and te:IsActiveType(TYPE_SPELL)
end
-- 效果发动条件：这张卡从场上送去墓地。
function c77411244.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中的同盟怪兽，且能加入手卡。
function c77411244.thfilter(c)
	return c:IsType(TYPE_UNION) and c:IsAbleToHand()
end
-- 检索效果的发动检测与操作信息设置：检查卡组中是否存在同盟怪兽，并设置检索的操作信息。
function c77411244.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查自己卡组是否存在至少1张满足条件的同盟怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c77411244.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组选择1只同盟怪兽加入手卡，并给对方确认。
function c77411244.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的同盟怪兽。
	local g=Duel.SelectMatchingCard(tp,c77411244.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
