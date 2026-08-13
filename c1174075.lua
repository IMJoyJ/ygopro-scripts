--竜輝巧－ファフμβ’
-- 效果：
-- 1星怪兽×2只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「龙辉巧」卡送去墓地。
-- ②：自己进行仪式召唤的场合，也能把那些解放的怪兽从这张卡的超量素材取除。
-- ③：自己场上有机械族仪式怪兽存在，对方把魔法·陷阱卡发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c1174075.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加超量召唤手续：可用1星怪兽2只以上作为超量素材进行超量召唤，对应“1星怪兽×2只以上”。
	aux.AddXyzProcedure(c,nil,1,2,nil,nil,99)
	-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「龙辉巧」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1174075,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1174075)
	e1:SetCondition(c1174075.tgcon)
	e1:SetTarget(c1174075.tgtg)
	e1:SetOperation(c1174075.tgop)
	c:RegisterEffect(e1)
	-- ②：自己进行仪式召唤的场合，也能把那些解放的怪兽从这张卡的超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_OVERLAY_RITUAL_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己场上有机械族仪式怪兽存在，对方把魔法·陷阱卡发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1174075,1))  --"无效并破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,1174076)
	e3:SetCondition(c1174075.discon)
	e3:SetCost(c1174075.discost)
	e3:SetTarget(c1174075.distg)
	e3:SetOperation(c1174075.disop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡是以超量召唤方式特殊召唤成功。
function c1174075.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选卡组中满足“「龙辉巧」卡”且能够送去墓地的卡。
function c1174075.tgfilter(c)
	return c:IsSetCard(0x154) and c:IsAbleToGrave()
end
-- ①效果的发动目标：确认卡组存在至少1张符合条件的「龙辉巧」卡，并设置从卡组送墓地的操作信息。
function c1174075.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在至少1张满足条件的「龙辉巧」卡且可以送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c1174075.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定本次效果处理为：从卡组将1张卡送去墓地，数量为1，目标位置为卡组，具体卡在处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：玩家从卡组选择1张符合条件的「龙辉巧」卡，将其送去墓地。
function c1174075.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选出1张满足条件的「龙辉巧」卡。
	local g=Duel.SelectMatchingCard(tp,c1174075.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ③效果的辅助过滤：我方场上存在表侧表示的机械族仪式怪兽。
function c1174075.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsRace(RACE_MACHINE)
end
-- ③效果的发动条件：这张卡未被战斗破坏确定，对方发动的魔法·陷阱卡连锁可被无效，且我方场上有机械族仪式怪兽存在。
function c1174075.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 该效果不在战斗破坏确定状态下，并且对方发动的连锁能够被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		and ep==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 我方场上存在至少1只表侧表示的机械族仪式怪兽。
		and Duel.IsExistingMatchingCard(c1174075.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ③效果的发动代价：取除这张卡的1个超量素材。
function c1174075.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③效果的发动目标：将对方发动的魔法·陷阱卡设为无效并破坏的对象，并设置对应操作信息。
function c1174075.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定本次效果处理包含“无效发动”，对象为对方发动的魔法·陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方发动的魔法·陷阱卡可被破坏且仍与该效果关联，则额外设定本次效果处理包含“破坏”该卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果的处理：无效对方发动的魔法·陷阱卡的发动，并破坏那张卡。
function c1174075.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果成功无效该连锁的发动，且被无效的卡仍与效果关联，则执行后续破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏对方发动的魔法·陷阱卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
