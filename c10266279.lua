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
-- 初始化卡片效果，注册灵摆效果和怪兽效果
function s.initial_effect(c)
	-- 记录卡片中记载了「狱神影精-朱诺白化精」与「调狱神 朱诺拉」的卡密码
	aux.AddCodeList(c,10266279,5914858)
	-- 添加灵摆怪兽属性，并注册灵摆卡发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡在灵摆区域存在的状态，自己场上有「狱神」怪兽或「耀圣」怪兽特殊召唤的场合才能发动。这张卡破坏，自己抽2张。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡效果"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ①：从卡组上面把3张卡里侧除外才能发动。这张卡破坏，从额外卡组把1只「调狱神 朱诺拉」当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡表侧加入额外卡组的场合才能发动。除「狱神影精-朱诺白化精」外的1张「狱神」卡或「耀圣」卡从自己的额外卡组（表侧）·墓地加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索效果"
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
-- 过滤自己场上表侧表示的「狱神」怪兽或「耀圣」怪兽
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x1ce,0x1d8) and c:IsFaceup()
end
-- 检查是否有自己场上表侧表示的「狱神」怪兽或「耀圣」怪兽特殊召唤成功
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 灵摆效果的发动准备，验证抽卡可能性并设置抽卡、丢弃手卡、破坏自身的操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否能够通过效果抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的处理对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的操作参数设置为抽卡张数2
	Duel.SetTargetParam(2)
	-- 设置抽卡分类的操作信息，预测为自己抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置自身丢弃手卡分类的操作信息，预测丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	-- 设置破坏分类的操作信息，将此卡自身设为要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 执行灵摆效果，破坏此卡并抽2张卡，之后选择自己1张手卡丢弃
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否和连锁关联，如果关联则将其通过效果破坏，破坏失败则终止效果
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 获取当前连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 使目标玩家通过效果抽2张卡，并检查是否成功抽了2张卡
	if Duel.Draw(p,2,REASON_EFFECT)==2 then
		-- 向玩家发出选择要丢弃的手卡提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让玩家从自己的手牌中选择1张可丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		if dg:GetCount()>0 then
			-- 打断效果的执行时点，使后续效果不视为与之前效果同时处理
			Duel.BreakEffect()
			-- 将选中的卡作为效果丢弃送去墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 过滤墓地中可用于代替除外支付代价的「绝境的狱神域-威利亚」
function s.costfilter(c,e,tp)
	return e:GetHandler():IsSetCard(0x1ce) and c:IsAbleToRemove() and c:IsHasEffect(99311889,tp)
end
-- 怪兽效果①的发动代价，判断是从卡组最上方里侧除外3张卡，还是通过墓地卡片的代替效果代替该代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 检查自己卡组里是否至少有3张卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		-- 或者自己墓地是否存在能够作为代替除外的卡
		or Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	if g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 检查自己卡组里是否至少有3张卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		-- 且（墓地中不存在可代替除外的卡
		and (not Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 或者玩家选择不使用墓地代替除外效果）
		or not Duel.SelectYesNo(tp,aux.Stringid(99311889,1))) then  --"是否作为代替把「绝境的狱神域-威利亚」除外？"
		-- 使紧接着的从卡组取出卡片的操作不进行自动洗卡检测
		Duel.DisableShuffleCheck()
		-- 将卡组最上方的3张卡作为代价里侧表示除外
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	else
		-- 向玩家发出选择要除外的卡片提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择自己墓地中1张代替除外的卡
		local sg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		local te=tc:IsHasEffect(99311889,tp)
		if te then
			te:UseCountLimit(tp)
			-- 将选中的卡作为代替效果的代价表侧表示除外
			Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
		end
	end
end
-- 过滤额外卡组中能当作同调召唤来特殊召唤的「调狱神 朱诺拉」
function s.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_SYNCHRO) and c:IsCode(5914858)
		-- 能够以同调召唤方式特殊召唤，且场上有能够出该额外卡组怪兽的空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 怪兽效果①的发动准备，检查必须作为同调素材的限制以及额外卡组中是否存在合法召唤目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 验证玩家是否必须使用特定怪兽作为同调素材的限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 且自己额外卡组存在符合特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置破坏分类的操作信息，将此怪兽自身设为要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置特殊召唤分类的操作信息，预测将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行怪兽效果①，将此卡破坏并从额外卡组将「调狱神 朱诺拉」当作同调召唤特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否和连锁关联，如果关联则将其通过效果破坏，破坏失败则终止效果
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 验证玩家是否必须使用特定怪兽作为同调素材的限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 向玩家发出选择要特殊召唤的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择额外卡组中符合特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选中的怪兽以同调召唤方式在自己场上表侧表示特殊召唤
	Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end
-- 怪兽效果②的发动条件，检查此卡是否在额外卡组表侧表示存在
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 过滤除「狱神影精-朱诺白化精」外，属于「狱神」或「耀圣」系列的、可加入手卡的卡片
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1ce,0x1d8) and c:IsAbleToHand()
		and c:IsFaceupEx()
end
-- 怪兽效果②的发动准备，检查自己墓地及额外卡组（表侧）是否存在回收目标，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地或额外卡组中是否有符合条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置加入手卡分类的操作信息，预测将从墓地或额外卡组回收1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 执行怪兽效果②，选择自己额外卡组（表侧）或墓地中1张「狱神」或「耀圣」卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择要加入手卡的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地（受王家长眠之谷影响）或额外卡组中符合条件的1张卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送回持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
