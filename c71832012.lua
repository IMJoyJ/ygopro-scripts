--六世壊＝パライゾス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「俱舍怒威族」怪兽加入手卡。
-- ②：自己场上的怪兽的攻击力·守备力上升场上的怪兽的属性种类×100。
-- ③：自己场上的「俱舍怒威族的香格里拉茧」把效果发动的场合，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含发动时的检索效果、提升攻防的永续效果以及香格里拉茧发动效果时的破坏效果。
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「俱舍怒威族」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的怪兽的攻击力·守备力上升场上的怪兽的属性种类×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：自己场上的「俱舍怒威族的香格里拉茧」把效果发动的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"场上1张卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中「俱舍怒威族」怪兽的条件函数。
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x189)
		and c:IsAbleToHand()
end
-- 作为卡片发动时的效果处理，玩家可以选择从卡组将1只「俱舍怒威族」怪兽加入手卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「俱舍怒威族」怪兽。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的怪兽，则询问玩家是否将其加入手卡。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把1只「俱舍怒威族」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片加入玩家手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤场上表侧表示且具有有效属性的怪兽的条件函数。
function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0
end
-- 计算攻防上升数值的辅助函数，数值为场上怪兽的属性种类数量乘以100。
function s.val(e,c)
	-- 获取双方场上所有表侧表示且具有属性的怪兽。
	local g=Duel.GetMatchingGroup(s.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 返回这些怪兽的属性种类数量乘以100的数值。
	return aux.GetAttributeCount(g)*100
end
-- 效果③的发动条件判定：必须是自己场上的「俱舍怒威族的香格里拉茧」在场上发动了效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁的效果在发动时的所在位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local rc=re:GetHandler()
	return bit.band(loc,LOCATION_ONFIELD)~=0 and rp==tp and rc:IsCode(73542331)
end
-- 效果③的靶向处理，确认场上是否存在可破坏的卡，并让玩家选择1张卡作为破坏对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 效果发动时的可行性检查，判断场上是否存在至少1张可以作为对象破坏的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为效果对象并将其设为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，表明此效果的处理为破坏选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的执行处理，将选中的对象卡片破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段被选为对象的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
