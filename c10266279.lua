--獄神影精－ジュノルド
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：这张卡在灵摆区域存在的状态，自己场上有「狱神」怪兽或「耀圣」怪兽特殊召唤的场合才能发动。这张卡破坏，自己抽2张。那之后，选自己1张手卡丢弃。
-- 【怪兽效果】
-- 这个卡名在规则上也当作「耀圣」卡使用。这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：从卡组上面把3张卡里侧除外才能发动。这张卡破坏，从额外卡组把1只「调狱神 朱诺拉」当作同调召唤作特殊召唤。
-- ②：这张卡表侧加入额外卡组的场合才能发动。除「狱神影精-朱诺白化精」外的1张「狱神」卡或「耀圣」卡从自己的额外卡组（表侧）·墓地加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 在卡片记述代码列表中添加“调狱神 朱诺拉”
	aux.AddCodeList(c,5914858)
	-- 为怪兽添加灵摆怪兽属性及灵摆卡的发动效果
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：这张卡在灵摆区域存在的状态，自己场上有「狱神」怪兽或「耀圣」怪兽特殊召唤的场合才能发动。这张卡破坏，自己抽2张。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- 这个卡名在规则上也当作「耀圣」卡使用。这个卡名的①的怪兽效果1回合只能使用1次。①：从卡组上面把3张卡里侧除外才能发动。这张卡破坏，从额外卡组把1只「调狱神 朱诺拉」当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的怪兽效果1回合只能使用1次。②：这张卡表侧加入额外卡组的场合才能发动。除「狱神影精-朱诺白化精」外的1张「狱神」卡或「耀圣」卡从自己的额外卡组（表侧）·墓地加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的“狱神”或“耀圣”怪兽
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x1ce,0x1d8) and c:IsFaceup()
end
-- 检查是否有符合条件的怪兽特殊召唤成功
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 灵摆效果的发动准备与合法性检查
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否具备抽2张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的操作对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的操作参数为2
	Duel.SetTargetParam(2)
	-- 设置连锁的操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置连锁的操作信息为丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置连锁的操作信息为破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果的处理逻辑
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否仍在场并执行破坏操作，若未破坏则不执行后续处理
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 获取连锁中预设的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 执行抽2张卡的操作并检查是否成功
	if Duel.Draw(p,2,REASON_EFFECT)==2 then
		-- 提示玩家选择要丢弃的手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		-- 让玩家从手卡选择1张可以丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切玩家手卡
		Duel.ShuffleHand(tp)
		if dg:GetCount()>0 then
			-- 中断效果处理，使后续的丢弃手卡处理不与抽卡同时进行
			Duel.BreakEffect()
			-- 将选中的卡作为效果丢弃送去墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 怪兽效果①的发动代价处理
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 检查卡组剩余卡片数量是否不少于3张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	-- 禁用接下来的洗卡检测，防止除外卡组顶端卡片时自动洗卡
	Duel.DisableShuffleCheck()
	-- 将卡组顶端的3张卡里侧除外作为发动代价
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 过滤满足条件的“调狱神 朱诺拉”
function s.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_SYNCHRO) and c:IsCode(5914858)
		-- 检查是否可以当作同调召唤特殊召唤，并确认额外怪兽区域是否有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 怪兽效果①的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否存在必须作为同调素材的限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在可特殊召唤的目标
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置连锁的操作信息为破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的处理逻辑
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 破坏这张卡，若未成功破坏则不执行后续处理
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 再次检查是否存在必须作为同调素材的限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从额外卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选中的怪兽以同调召唤方式特殊召唤
	Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end
-- 检查这张卡是否表侧加入额外卡组
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 过滤除同名卡外的“狱神”或“耀圣”卡片
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1ce,0x1d8) and c:IsAbleToHand()
		and c:IsFaceupEx()
end
-- 怪兽效果②的发动准备与合法性检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地或额外卡组是否存在可加入手卡的目标
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁的操作信息为将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 怪兽效果②的处理逻辑
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从墓地或额外卡组选择1张符合条件的卡（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
