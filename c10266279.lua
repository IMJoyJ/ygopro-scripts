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
-- 初始化卡片效果与属性注册
function s.initial_effect(c)
	-- 注册卡片记载的卡片密码列表（包含自身卡号及额外卡组怪兽卡号）
	aux.AddCodeList(c,10266279,5914858)
	-- 开启灵摆怪兽的灵摆效果与灵摆召唤等灵摆属性
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡在灵摆区域存在的状态，自己场上有「狱神」怪兽或「耀圣」怪兽特殊召唤的场合才能发动。这张卡破坏，自己抽2张。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡效果"
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
-- 过滤自己场上表侧表示「狱神」怪兽或「耀圣」怪兽的过滤函数
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x1ce,0x1d8) and c:IsFaceup()
end
-- 灵摆效果1的发动条件判定（有「狱神」或「耀圣」怪兽特殊召唤成功）
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 灵摆效果1的发动目标判定与操作信息注册（包含抽卡、丢弃手牌、破坏自身）
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己是否能够抽2张卡作为发动的可行性判断
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前效果处理的目标玩家设定为自己
	Duel.SetTargetPlayer(tp)
	-- 将效果处理的目标参数设定为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 向系统注册效果分类信息为：抽卡，数量为2张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 向系统注册效果分类信息为：丢弃手牌，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 向系统注册效果分类信息为：破坏，对象为自身卡片（1张）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果1的效果处理逻辑（破坏自身并抽2张卡，那之后丢弃1张手牌）
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身卡片仍与连锁关联并执行破坏，破坏未成功则终止后续处理
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 获取效果处理的目标玩家参数（即抽卡玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 执行抽2张卡操作，成功抽满2张时执行后续的丢弃手牌处理
	if Duel.Draw(p,2,REASON_EFFECT)==2 then
		-- 给玩家显示选择要丢弃手牌的系统提示文字
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让玩家从手牌中选择1张可以丢弃的卡片
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切自己手牌以重新随机化手牌顺序
		Duel.ShuffleHand(tp)
		if dg:GetCount()>0 then
			-- 中断当前效果处理，使后续的丢弃手牌与前面的抽卡不视为同时处理（造成错时点）
			Duel.BreakEffect()
			-- 将被选中的卡片作为效果以及丢弃的原因送去墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 过滤墓地中满足「绝境的狱神域-威利亚」代替除外Cost条件的卡片过滤函数
function s.costfilter(c,e,tp)
	return e:GetHandler():IsSetCard(0x1ce) and c:IsAbleToRemove() and c:IsHasEffect(99311889,tp)
end
-- 怪兽效果1的物理Cost处理判定（从卡组最上方里侧除外3张卡，或用墓地卡片代替除外）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家卡组最上方的3张卡片
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 判定卡组中的卡片数量是否大于等于3张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		-- 或者墓地中存在满足代替除外Cost过滤条件的卡片作为发动判定
		or Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	if g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 再次判定卡组中卡片数量是否不小于3张以满足除外条件
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		-- 在不满足/不采用墓地代替除外Cost的卡片时
		and (not Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 或者玩家选择不使用墓地的卡片作为代替Cost除外时
		or not Duel.SelectYesNo(tp,aux.Stringid(99311889,1))) then  --"是否作为代替把「绝境的狱神域-威利亚」除外？"
		-- 禁用系统在紧接着的卡片移动操作后的洗牌检测（里侧除外不触发系统自动洗牌）
		Duel.DisableShuffleCheck()
		-- 将卡组最上方的3张卡以里侧表示作为Cost除外
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	else
		-- 给玩家显示选择要除外卡片的系统提示文字
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择墓地中1张作为代替除外Cost的卡片
		local sg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		local te=tc:IsHasEffect(99311889,tp)
		if te then
			te:UseCountLimit(tp)
			-- 将作为代替除外Cost的卡片以表侧表示进行除外
			Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
		end
	end
end
-- 过滤额外卡组中满足同调召唤条件的「调狱神 朱诺拉」的过滤函数
function s.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_SYNCHRO) and c:IsCode(5914858)
		-- 判断是否可以当作同调召唤来特殊召唤，且额外怪兽区域有空余召唤位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 怪兽效果1的发动目标判定与操作信息注册（包含破坏自身与特殊召唤）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定当前是否有必须作为同调素材的限制性检测作为发动的可行性判断
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 且额外卡组中存在能够特殊召唤的「调狱神 朱诺拉」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 向系统注册效果分类信息为：破坏自身卡片（1张）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 向系统注册效果分类信息为：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果1的效果处理逻辑（破坏自身并从额外卡组当作同调召唤特殊召唤「调狱神 朱诺拉」）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身卡片仍与连锁关联并执行破坏自身，未成功破坏则终止处理
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 在效果处理时再次确认是否满足同调素材的限制性检测
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 给玩家显示特殊召唤卡片的系统提示文字
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组中选择1只满足特殊召唤条件的「调狱神 朱诺拉」
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选择的怪兽当作同调召唤特殊召唤到场上
	Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end
-- 怪兽效果2的发动条件判定（这张卡在额外卡组表侧表示存在）
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 过滤墓地或额外卡组表侧中除同名卡外的「狱神」卡或「耀圣」卡且能加入手牌的过滤函数
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1ce,0x1d8) and c:IsAbleToHand()
		and c:IsFaceupEx()
end
-- 怪兽效果2的发动目标判定与操作信息注册（检索卡片加入手牌）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定额外卡组表侧或墓地中是否存在满足检索条件的卡片作为发动判定
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 向系统注册效果分类信息为：加入手牌，数量为1张，位置为额外卡组或墓地
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 怪兽效果2的效果处理逻辑（从额外卡组表侧或墓地选卡加入手牌）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示将卡片加入手牌的系统提示文字
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从受王家长眠之谷影响过滤后的额外卡组表侧或墓地中选择1张卡片
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将被选中的卡片以效果原因为由加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家出示并确认被加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
