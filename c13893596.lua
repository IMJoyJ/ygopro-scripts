--究極封印神エクゾディオス
-- 效果：
-- 这张卡不能通常召唤。让自己墓地的怪兽全部回到卡组·额外卡组的场合才能特殊召唤。这张卡的②的效果让「被封印」怪兽5种类被送去自己墓地全部齐集时，自己决斗胜利。
-- ①：这张卡的攻击力上升自己墓地的通常怪兽数量×1000。
-- ②：这张卡的攻击宣言时发动。从手卡·卡组把1只怪兽送去墓地。
-- ③：表侧表示的这张卡从场上离开的场合除外。
function c13893596.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 让自己墓地的怪兽全部回到卡组·额外卡组的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c13893596.spcon)
	e2:SetOperation(c13893596.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击宣言时发动。从手卡·卡组把1只怪兽送去墓地。这张卡的②的效果让「被封印」怪兽5种类被送去自己墓地全部齐集时，自己决斗胜利。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13893596,0))  --"怪兽送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c13893596.tgtg)
	e3:SetOperation(c13893596.tgop)
	c:RegisterEffect(e3)
	-- ①：这张卡的攻击力上升自己墓地的通常怪兽数量×1000。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(c13893596.atkval)
	c:RegisterEffect(e4)
	-- 为这张卡添加“表侧表示的这张卡从场上离开的场合除外”的重定向效果，对应③：表侧表示的这张卡从场上离开的场合除外。
	aux.AddBanishRedirect(c)
end
-- 判断墓地怪兽是否都能作为代价返回卡组·额外卡组；若存在不能返回的怪兽则返回true，使特殊召唤条件不成立。
function c13893596.cfilter(c)
	return not c:IsAbleToDeckOrExtraAsCost()
end
-- 检查是否满足这张卡的特殊召唤条件：自己主要怪兽区有空位，且自己墓地存在怪兽且所有墓地怪兽都能作为代价回到卡组·额外卡组。
function c13893596.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中的所有怪兽。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	-- 判断自己主要怪兽区是否有空位，且自己墓地存在怪兽。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0
		and not g:IsExists(c13893596.cfilter,1,nil)
end
-- 特殊召唤手续：将自己墓地存在的所有怪兽返回持有者卡组并洗切，作为特殊召唤的代价。
function c13893596.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取自己墓地中的所有怪兽。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	-- 将墓地中的所有怪兽返回卡组（占用底部位置）并洗牌，处理原因视为特殊召唤。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
end
-- ②的发动时点：这张卡攻击宣言时必发发动；发动时设置效果处理时将从卡组送1只怪兽去墓地的操作信息。
function c13893596.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果处理时将1张卡送去墓地，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 选择条件：怪兽卡且能被效果送去墓地。
function c13893596.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 判断墓地中的卡是否为与这张卡建立了关联的「被封印」怪兽。
function c13893596.filter(c,rc)
	return c:IsRelateToCard(rc) and c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER)
end
-- ②的效果处理：从手卡·卡组选1只怪兽送去墓地；若这张卡仍在场且墓地的「被封印」怪兽达到5种类，则我方以艾克佐迪奥斯胜利条件获得决斗胜利。
function c13893596.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local c=e:GetHandler()
	-- 从自己的手卡和卡组中选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c13893596.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 确认所选怪兽成功被效果送去墓地、送墓后仍在墓地，且这张卡与当前效果仍有关联。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		-- 获取自己墓地中所有与这张卡关联且为「被封印」的怪兽。
		local g=Duel.GetMatchingGroup(c13893596.filter,tp,LOCATION_GRAVE,0,nil,c)
		if c:GetOriginalCode()==13893596 and c:IsFaceup() and g:IsContains(tc) and g:GetClassCount(Card.GetCode)==5 then
			local WIN_REASON_EXODIUS = 0x14
			-- 当前效果处理完成后，我方以艾克佐迪奥斯胜利条件（WIN_REASON_EXODIUS）获得决斗胜利。
			Duel.Win(tp,WIN_REASON_EXODIUS)
		end
	end
end
-- 计算这张卡的攻击力上升值：自己墓地中通常怪兽数量×1000。
function c13893596.atkval(e,c)
	-- 返回自己墓地通常怪兽数量×1000作为攻击力加成。
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_NORMAL)*1000
end
