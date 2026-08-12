--聖天樹の大母神
-- 效果：
-- 连接怪兽2只以上
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「圣天树」魔法·陷阱卡加入手卡。
-- ②：这张卡不会被对方的效果破坏，不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
-- ③：1回合1次，把这张卡所连接区1只自己的连接怪兽解放才能发动。选最多有那个连接标记数量的对方场上的卡破坏。
function c92770064.initial_effect(c)
	-- 设置连接召唤的手续，需要2只以上的连接怪兽作为素材。
	aux.AddLinkProcedure(c,c92770064.mfilter,2,99)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「圣天树」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92770064,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c92770064.thcon)
	e1:SetTarget(c92770064.thtg)
	e1:SetOperation(c92770064.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方的效果破坏的效果值。
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- ③：1回合1次，把这张卡所连接区1只自己的连接怪兽解放才能发动。选最多有那个连接标记数量的对方场上的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92770064,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c92770064.cost)
	e3:SetTarget(c92770064.destg)
	e3:SetOperation(c92770064.desop)
	c:RegisterEffect(e3)
end
-- 连接素材过滤条件：连接怪兽。
function c92770064.mfilter(c)
	return c:IsLinkType(TYPE_LINK)
end
-- 检索效果的发动条件：这张卡连接召唤成功。
function c92770064.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索卡片的过滤条件：卡名含有「圣天树」的魔法·陷阱卡，且能加入手卡。
function c92770064.thfilter(c)
	return c:IsSetCard(0x2158) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的发动检测与效果处理准备函数。
function c92770064.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己卡组是否存在至少1张满足过滤条件的「圣天树」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c92770064.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数：从卡组选择1张「圣天树」魔法·陷阱卡加入手卡并给对方确认。
function c92770064.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足过滤条件的「圣天树」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c92770064.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏效果的发动代价函数，用于标记需要进行解放的操作。
function c92770064.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 破坏目标的过滤条件：不是解放怪兽的装备卡，且不是解放怪兽自身。
function c92770064.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 可解放怪兽的过滤条件：属于这张卡的所连接区、是连接怪兽、连接标记数量大于等于1，且解放后对方场上存在可破坏的卡。
function c92770064.costfilter(c,ec,tp,g)
	-- 检查对方场上是否存在可破坏的卡，且该怪兽在所连接区内、是连接怪兽、连接标记数量大于等于1。
	return Duel.IsExistingTarget(c92770064.desfilter,tp,0,LOCATION_ONFIELD,1,c,c,ec) and g:IsContains(c) and c:IsType(TYPE_LINK) and c:IsLinkAbove(1)
end
-- 破坏效果的发动检测与效果处理准备函数。
function c92770064.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local ct=0
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 在发动检测时，检查自己场上是否存在至少1只满足解放条件的怪兽。
			return Duel.CheckReleaseGroup(tp,c92770064.costfilter,1,c,c,tp,lg)
		else
			-- 在发动检测时，检查对方场上是否存在至少1张卡。
			return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 从场上选择1只满足解放条件的怪兽。
		local g=Duel.SelectReleaseGroup(tp,c92770064.costfilter,1,1,c,c,tp,lg)
		ct=g:GetFirst():GetLink()
		-- 解放选中的怪兽作为发动代价。
		Duel.Release(g,REASON_COST)
	end
	e:SetValue(ct)
	-- 获取对方场上的所有卡。
	local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理的操作信息：破坏对方场上的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
end
-- 破坏效果的执行函数：选最多有解放怪兽连接标记数量的对方场上的卡破坏。
function c92770064.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetValue()
	-- 获取对方场上的所有卡。
	local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 给玩家发送提示信息：选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local g=sg:Select(tp,1,ct,nil)
	if #g>0 then
		-- 手动为选中的卡显示被选为对象的动画效果。
		Duel.HintSelection(g)
		-- 将选中的卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
