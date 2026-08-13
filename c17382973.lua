--プランキッズ・ドゥードゥル
-- 效果：
-- 「调皮宝贝」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「调皮宝贝」魔法·陷阱卡加入手卡。
-- ②：把这张卡解放，以连接怪兽以外的自己墓地2张「调皮宝贝」卡为对象才能发动（同名卡最多1张）。那些卡加入手卡。
function c17382973.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只「调皮宝贝」怪兽作为连接素材才能连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x120),2)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤成功的场合才能发动。从卡组把1张「调皮宝贝」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17382973,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,17382973)
	e1:SetCondition(c17382973.thcon)
	e1:SetTarget(c17382973.thtg)
	e1:SetOperation(c17382973.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以连接怪兽以外的自己墓地2张「调皮宝贝」卡为对象才能发动（同名卡最多1张）。那些卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17382973,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,17382974)
	e2:SetCost(c17382973.thcost2)
	e2:SetTarget(c17382973.thtg2)
	e2:SetOperation(c17382973.thop2)
	c:RegisterEffect(e2)
end
-- 发动条件判定：该卡必须是连接召唤成功（SUMMON_TYPE_LINK）时才能满足①效果的发动条件。
function c17382973.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索筛滤条件：卡名属于「调皮宝贝」字段、是魔法陷阱卡、且可以加入手卡。
function c17382973.thfilter(c)
	return c:IsSetCard(0x120) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动时点判定与连锁登记：确认卡组存在可检索的「调皮宝贝」魔法陷阱卡，并登记从卡组将1张卡加入手卡的连锁信息。
function c17382973.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查（chk==0）：卡组中存在至少1张符合条件的「调皮宝贝」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c17382973.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次连锁将从卡组把1张卡加入手卡（分类为TOHAND+SEARCH），供后续效果连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家从卡组选择1张符合条件的「调皮宝贝」魔法·陷阱卡加入手卡，并给对方确认。
function c17382973.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 执行检索：从卡组筛选并选择1张符合条件的「调皮宝贝」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c17382973.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡（原因REASON_EFFECT，即效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- COST候选筛滤：选择位于表侧表示或墓地、可作为COST除外、且拥有25725326号代替解放效果的卡，用于替代解放。
function c17382973.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 判断某张卡能否作为COST：在选择该卡作为解放/代替解放后，墓地目标组中仍至少存在2种不同卡名的「调皮宝贝」卡，从而能选出2张同名不同的对象。
function c17382973.costfilter(c,tp,g)
	local tg=g:Clone()
	tg:RemoveCard(c)
	return tg:GetClassCount(Card.GetCode)>=2
end
-- ②效果的COST处理：收集可代替解放除外的候选卡与自身；在合法时设置标记供取对象阶段使用；实际支付时选择一张候选，若其具有25725326号代替解放效果则表侧除外代替解放，否则将其解放。
function c17382973.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	-- 生成可代替解放的COST候选组（表侧表示或在墓地、可除外、且拥有25725326号效果的卡）。
	local g=Duel.GetMatchingGroup(c17382973.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 生成墓地中可作为效果对象的「调皮宝贝」非连接怪兽候选组（可被取对象且可加入手卡）。
	local tg=Duel.GetMatchingGroup(c17382973.thfilter2,tp,LOCATION_GRAVE,0,nil,e)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then
		e:SetLabel(100)
		return g:IsExists(c17382973.costfilter,1,nil,tp,tg)
	end
	local cg=g:Filter(c17382973.costfilter,nil,tp,tg)
	local tc
	if #cg>1 then
		-- 提示玩家选择要解放或代替解放除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=cg:Select(tp,1,1,nil):GetFirst()
	else
		tc=cg:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 代替解放处理：将选定的卡表侧表示除外，作为COST（REASON_COST+REASON_REPLACE）。
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 通常解放处理：将选定的卡解放，作为COST（一般是解放这张卡自身）。
		Duel.Release(tc,REASON_COST)
	end
end
-- 墓地取对象筛滤：属于「调皮宝贝」字段、不是连接怪兽、能被效果取对象且能加入手卡。
function c17382973.thfilter2(c,e)
	return c:IsSetCard(0x120) and not c:IsType(TYPE_LINK)
		and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- ②效果的取对象目标设定：仅在COST已支付（标签为100）时执行；从墓地符合条件的卡中选择2张卡名不同的「调皮宝贝」卡作为对象，并登记加入手卡的连锁信息。
function c17382973.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetLabel()==100 end
	e:SetLabel(0)
	-- 获取墓地中所有符合条件的「调皮宝贝」非连接怪兽。
	local g=Duel.GetMatchingGroup(c17382973.thfilter2,tp,LOCATION_GRAVE,0,nil,e)
	-- 弹出目标选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从候选组中选择2张卡，且2张卡卡名互不相同（同名卡最多1张）。
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选择的2张卡设置为当前连锁的取对象目标。
	Duel.SetTargetCard(g1)
	-- 登记操作信息：本次连锁将这2张对象卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ②效果处理：将连锁对象中仍与效果相关的卡（仍可加入手卡）加入手卡。
function c17382973.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象卡组，并过滤出仍然与效果相关（未被无效/未离场等）的对象卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将处理时仍有效的对象卡加入手卡（效果处理原因REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
