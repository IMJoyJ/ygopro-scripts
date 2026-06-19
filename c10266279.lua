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
-- 初始化效果：添加效果相关卡片列表，启用灵摆属性，注册灵摆效果，注册怪兽的主动特殊召唤和被送去额外卡组的检索效果
function s.initial_effect(c)
	-- 将「狱神影精-朱诺白化精」与「调狱神 朱诺拉」加入此卡的关联卡片列表中
	aux.AddCodeList(c,10266279,5914858)
	-- 为怪兽卡设置灵摆属性（注册灵摆召唤以及在灵摆区域的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡在灵摆区域存在的状态，自己场上有「狱神」怪兽或「耀圣」怪兽特殊召唤的场合才能发动。这张卡破坏，自己抽2张。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
-- 特殊召唤检测过滤条件：是由自己控制且在场上表侧表示存在的「狱神」怪兽或「耀圣」怪兽
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x1ce,0x1d8) and c:IsFaceup()
end
-- 抽卡效果的发动条件：自己场上有「狱神」怪兽或「耀圣」怪兽特殊召唤的场合
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 抽卡效果的靶指向与发动检测：检查玩家是否可以抽卡，并设置连锁操作信息为破坏此卡、抽卡以及丢弃手卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能抽2张卡并返回结果
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为2（表示抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置连锁操作信息为让玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 抽卡效果的效果处理：此卡破坏，自己抽2张，之后选择自己1张手牌丢弃
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡已不关联当前连锁或破坏失败，则停止效果处理
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 获取当前连锁中被设定为对象玩家的玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让玩家因效果抽2张卡，若成功抽了2张则执行后续处理
	if Duel.Draw(p,2,REASON_EFFECT)==2 then
		-- 向发动效果的玩家提示选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让玩家从手牌中选择1张可以丢弃的卡片
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		if dg:GetCount()>0 then
			-- 中断当前效果处理，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将选择的卡片因效果丢弃送去墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 除外代替效果的过滤条件：是「狱神」卡片，可以被除外且在墓地存在适用的代替效果
function s.costfilter(c,e,tp)
	return e:GetHandler():IsSetCard(0x1ce) and c:IsAbleToRemove() and c:IsHasEffect(99311889,tp)
end
-- 特殊召唤效果的代价：从卡组上面将3张卡里侧除外（或者作为代替把墓地的「绝境的狱神域-威利亚」除外）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 并且玩家卡组的卡片数量大于等于3张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		-- 或者墓地中存在可以用作代替除外的卡片并结束发动检测
		or Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	if g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 并且玩家卡组的卡片数量大于等于3张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		-- 并且若墓地中不存在代替除外的卡片
		and (not Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 或者玩家选择不进行代替除外，则执行正常除外代价
		or not Duel.SelectYesNo(tp,aux.Stringid(99311889,1))) then  --"是否作为代替把「绝境的狱神域-威利亚」除外？"
		-- 使接下来的操作不进行洗卡检测
		Duel.DisableShuffleCheck()
		-- 将卡组最上方的3张卡里侧表示除外
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	else
		-- 向发动效果的玩家提示选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从墓地中选择1张用于代替除外的卡片
		local sg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		local te=tc:IsHasEffect(99311889,tp)
		if te then
			te:UseCountLimit(tp)
			-- 将选中的代替卡片表侧表示除外以作为代替代价
			Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
		end
	end
end
-- 特殊召唤的过滤条件：是同调怪兽，卡名为「调狱神 朱诺拉」，可以被当作同调召唤来特殊召唤，且场上有其出场的格子
function s.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_SYNCHRO) and c:IsCode(5914858)
		-- 且可以被当作同调召唤来特殊召唤，并且场上有其出场的额外怪兽区域或所连接的区域空格
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 特殊召唤效果的靶指向与发动检测：检查是否满足同调素材检测并存在可特殊召唤的卡，设置连锁操作信息为破坏自身与特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否满足必须成为同调素材的检测
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 并且额外卡组是否存在可以特殊召唤的「调狱神 朱诺拉」并返回结果
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置连锁操作信息为将此卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果的效果处理：破坏此卡，并将额外卡组的1只「调狱神 朱诺拉」当作同调召唤特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡已不关联当前连锁或破坏失败，则停止效果处理
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 若玩家不满足必须成为同调素材的检测，则停止效果处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 向发动效果的玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足特殊召唤条件的「调狱神 朱诺拉」
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选中的怪兽当作同调召唤表侧表示特殊召唤
	Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end
-- 检索效果的发动条件：此卡在额外卡组表侧表示存在
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 检索卡片的过滤条件：卡名不是「狱神影精-朱诺白化精」，属于「狱神」或「耀圣」系列，可以加入手牌，且在墓地或额外卡组表侧表示存在
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1ce,0x1d8) and c:IsAbleToHand()
		and c:IsFaceupEx()
end
-- 检索效果的靶指向与发动检测：检查墓地或额外卡组是否存在可以加入手牌的关联卡，并设置连锁操作信息为将卡片加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地及额外卡组中是否存在满足条件的卡片并返回结果
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息为从墓地或额外卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 检索效果的效果处理：从额外卡组（表侧）或墓地选择除「狱神影精-朱诺白化精」外的1张「狱神」卡或「耀圣」卡加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从受「王家长眠之谷」影响过滤后的墓地及额外卡组表侧卡片中选择1张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
