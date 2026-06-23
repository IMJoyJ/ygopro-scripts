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
	-- 这张卡的攻击宣言时发动。从手卡·卡组把1只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13893596,0))  --"怪兽送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c13893596.tgtg)
	e3:SetOperation(c13893596.tgop)
	c:RegisterEffect(e3)
	-- 这张卡的攻击力上升自己墓地的通常怪兽数量×1000。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(c13893596.atkval)
	c:RegisterEffect(e4)
	-- 表侧表示的这张卡从场上离开的场合除外。
	aux.AddBanishRedirect(c)
end
-- 过滤函数，用于判断墓地中的怪兽是否能被送回卡组或额外卡组。
function c13893596.cfilter(c)
	return not c:IsAbleToDeckOrExtraAsCost()
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件。
function c13893596.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家墓地中所有怪兽的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	-- 判断玩家场上是否有足够的怪兽区域，并且墓地中有怪兽存在。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0
		and not g:IsExists(c13893596.cfilter,1,nil)
end
-- 特殊召唤时的操作函数，将墓地中的所有怪兽送回卡组。
function c13893596.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取玩家墓地中所有怪兽的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	-- 将指定的卡片组送回卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
end
-- 设置攻击宣言时的效果目标函数。
function c13893596.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定将要处理的卡片类型为送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于选择可以送去墓地的怪兽。
function c13893596.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 过滤函数，用于判断墓地中的怪兽是否与当前效果相关。
function c13893596.filter(c,rc)
	return c:IsRelateToCard(rc) and c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER)
end
-- 攻击宣言时的效果处理函数。
function c13893596.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择将怪兽送去墓地。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local c=e:GetHandler()
	-- 从玩家手牌或卡组中选择一张怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c13893596.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断所选怪兽是否成功送去墓地，并且与当前效果相关。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		-- 获取与当前效果相关的墓地怪兽组。
		local g=Duel.GetMatchingGroup(c13893596.filter,tp,LOCATION_GRAVE,0,nil,c)
		if c:GetOriginalCode()==13893596 and c:IsFaceup() and g:IsContains(tc) and g:GetClassCount(Card.GetCode)==5 then
			local WIN_REASON_EXODIUS = 0x14
			-- 令当前玩家以特定理由决斗胜利。
			Duel.Win(tp,WIN_REASON_EXODIUS)
		end
	end
end
-- 计算攻击力增加数值的函数。
function c13893596.atkval(e,c)
	-- 计算玩家墓地中通常怪兽数量并乘以1000作为攻击力增加值。
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_NORMAL)*1000
end
