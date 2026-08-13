--D・スキャナン
-- 效果：
-- 这张卡不能通常召唤。从手卡把1只「变形斗士」怪兽除外的场合可以特殊召唤。
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：1回合1次，自己主要阶段才能发动。从卡组把1张「变形斗士」魔法·陷阱卡加入手卡。那之后，选1张手卡回到卡组最上面。
-- ●守备表示：1回合1次，自己主要阶段才能发动。从自己墓地选1只4星以下的「变形斗士」怪兽加入手卡。那之后，选1张手卡回到卡组最上面。
function c1876841.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从手卡把1只「变形斗士」怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1876841.spcon)
	e1:SetTarget(c1876841.sptg)
	e1:SetOperation(c1876841.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡得到表示形式的以下效果。●攻击表示：1回合1次，自己主要阶段才能发动。从卡组把1张「变形斗士」魔法·陷阱卡加入手卡。那之后，选1张手卡回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1876841,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c1876841.srcon)
	e2:SetTarget(c1876841.srtg)
	e2:SetOperation(c1876841.srop)
	c:RegisterEffect(e2)
	-- ①：这张卡得到表示形式的以下效果。●守备表示：1回合1次，自己主要阶段才能发动。从自己墓地选1只4星以下的「变形斗士」怪兽加入手卡。那之后，选1张手卡回到卡组最上面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1876841,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c1876841.rccon)
	e3:SetTarget(c1876841.rctg)
	e3:SetOperation(c1876841.rcop)
	c:RegisterEffect(e3)
end
-- 过滤函数：手卡中的「变形斗士」怪兽且可以作为COST被除外。
function c1876841.spfilter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则条件：若c为空则允许规则询问；否则要求自己主要怪兽区有空位，且手卡存在可除外的「变形斗士」怪兽（排除此卡自身）。
function c1876841.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上主要怪兽区是否有可用空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1张满足条件的「变形斗士」怪兽（排除发动规则的这张卡自身）。
		and Duel.IsExistingMatchingCard(c1876841.spfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
end
-- 特殊召唤规则的目标选择：从手卡选择1张可除外的「变形斗士」怪兽作为COST，并存入e的LabelObject；选到则返回true。
function c1876841.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中所有可作为COST除外的「变形斗士」怪兽（排除自身）。
	local g=Duel.GetMatchingGroup(c1876841.spfilter,tp,LOCATION_HAND,0,e:GetHandler())
	-- 显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的处理：取出之前选择的COST卡并将其除外，完成特殊召唤手续。
function c1876841.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的卡以表侧表示除外，除外原因记为特殊召唤（作为特殊召唤COST）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 攻击表示效果的发动条件：此卡效果没有被无效，且处于攻击表示。
function c1876841.srcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 过滤函数：卡组中的「变形斗士」魔法·陷阱卡且可以加入手卡。
function c1876841.srfilter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 攻击表示效果的发动判定与操作信息：检查卡组有检索目标；设置1张卡从卡组加入手卡、1张手卡返回卡组的操作信息。
function c1876841.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：卡组中存在至少1张符合条件的「变形斗士」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1876841.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果操作信息：本次效果会将1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置效果操作信息：本次效果会将1张手卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 攻击表示效果处理：从卡组选1张「变形斗士」魔法·陷阱卡加入手卡，给对方确认并洗切卡组；然后选1张手卡返回卡组顶。
function c1876841.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「变形斗士」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c1876841.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若检索卡存在、成功加入手卡且现在确实在手牌，才继续执行后续回卡组处理。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将检索到的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切卡组。
		Duel.ShuffleDeck(tp)
		-- 显示“请选择要返回卡组的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡选择1张可以返回卡组的卡。
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使之后的手卡回卡组操作作为不同时处理的独立效果，避免错误时点。
			Duel.BreakEffect()
			-- 洗切手卡。
			Duel.ShuffleHand(tp)
			-- 将选中的手卡以效果送回持有者卡组最顶端。
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
-- 守备表示效果的发动条件：此卡效果没有被无效，且处于守备表示。
function c1876841.rccon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 过滤函数：墓地中的「变形斗士」怪兽且等级4以下，可以加入手卡。
function c1876841.rcfilter(c)
	return c:IsSetCard(0x26) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 守备表示效果的发动判定与操作信息：检查墓地有对象；设置1张卡从墓地加入手卡、1张手卡返回卡组的操作信息。
function c1876841.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：墓地中存在至少1只符合条件的4星以下「变形斗士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c1876841.rcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果操作信息：本次效果会将1张卡从墓地加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置效果操作信息：本次效果会将1张手卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 守备表示效果处理：从墓地选1只4星以下「变形斗士」怪兽加入手卡，然后选1张手卡返回卡组顶。
function c1876841.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1只符合条件的「变形斗士」怪兽（使用王家长眠之谷过滤，排除受其影响不能移动的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1876841.rcfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	-- 若选中的墓地卡存在、成功加入手卡且现在确实在手牌，才继续执行后续回卡组处理。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 显示“请选择要返回卡组的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡选择1张可以返回卡组的卡。
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使之后的手卡回卡组操作作为不同时处理的独立效果。
			Duel.BreakEffect()
			-- 洗切手卡。
			Duel.ShuffleHand(tp)
			-- 将选中的手卡以效果送回持有者卡组最顶端。
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
