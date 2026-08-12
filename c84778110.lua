--フリント・クラッガー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。选自己1张手卡丢弃，从额外卡组把1只「化石」融合怪兽送去墓地。
-- ②：把场上的这张卡送去墓地才能发动。给与对方500伤害。自己墓地有「化石融合」存在的场合，可以再选除外的自己1张「化石融合」或者1张有那个卡名记述的卡回到墓地。
function c84778110.initial_effect(c)
	-- 注册卡片记述的卡片密码（化石融合）
	aux.AddCodeList(c,59419719)
	-- ①：这张卡特殊召唤成功的场合才能发动。选自己1张手卡丢弃，从额外卡组把1只「化石」融合怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84778110,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,84778110)
	e1:SetTarget(c84778110.tgtg)
	e1:SetOperation(c84778110.tgop)
	c:RegisterEffect(e1)
	-- ②：把场上的这张卡送去墓地才能发动。给与对方500伤害。自己墓地有「化石融合」存在的场合，可以再选除外的自己1张「化石融合」或者1张有那个卡名记述的卡回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84778110,1))  --"除外的卡回到墓地"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,84778111)
	e2:SetCost(c84778110.damcost)
	e2:SetTarget(c84778110.damtg)
	e2:SetOperation(c84778110.damop)
	c:RegisterEffect(e2)
end
-- 过滤额外卡组中可以送去墓地的「化石」融合怪兽
function c84778110.tgfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x149) and c:IsAbleToGrave()
end
-- 效果①的发动条件与对象检测（手牌有卡且额外卡组有符合条件的「化石」融合怪兽）
function c84778110.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查额外卡组是否存在至少1只可以送去墓地的「化石」融合怪兽
		and Duel.IsExistingMatchingCard(c84778110.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的处理：丢弃1张手牌，并将额外卡组的1只「化石」融合怪兽送去墓地
function c84778110.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择并丢弃1张手牌，若成功丢弃则继续执行
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从额外卡组选择1只符合条件的「化石」融合怪兽
		local g=Duel.SelectMatchingCard(tp,c84778110.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 效果②的发动代价：将场上的这张卡送去墓地
function c84778110.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为发动代价的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果②的发动准备与伤害效果分类设置
function c84778110.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表示该效果包含给与对方500点伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 过滤除外状态下表侧表示的「化石融合」或记述了该卡名的卡片
function c84778110.rfilter(c)
	-- 检查卡片是否为「化石融合」或记述了该卡名，且为表侧表示
	return aux.IsCodeOrListed(c,59419719) and c:IsFaceup()
end
-- 过滤墓地中的「化石融合」
function c84778110.cfilter(c)
	return c:IsCode(59419719)
end
-- 效果②的处理：给与对方500伤害，并根据条件选择是否让除外的「化石融合」或其相关卡回到墓地
function c84778110.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与对方500点伤害，若伤害成功造成则继续执行后续处理
	if Duel.Damage(1-tp,500,REASON_EFFECT)~=0
		-- 检查自己墓地是否存在「化石融合」
		and Duel.IsExistingMatchingCard(c84778110.cfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己被除外的卡中是否存在符合条件的卡
		and Duel.IsExistingMatchingCard(c84778110.rfilter,tp,LOCATION_REMOVED,0,1,nil)
		-- 询问玩家是否选择除外的卡回到墓地
		and Duel.SelectYesNo(tp,aux.Stringid(84778110,2)) then  --"是否选除外的卡回到墓地？"
		-- 中断当前效果处理，使后续的回到墓地处理不与伤害同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择1张除外的「化石融合」或记述了该卡名的卡
		local sg=Duel.SelectMatchingCard(tp,c84778110.rfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		-- 确认并向双方玩家展示所选择的卡片
		Duel.HintSelection(sg)
		-- 将选中的卡送回墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
