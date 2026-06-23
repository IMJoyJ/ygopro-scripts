--陽炎獣 スピンクス
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。此外，自己的主要阶段时，宣言卡的种类（怪兽·魔法·陷阱）才能发动。自己卡组最上面的卡送去墓地，宣言的种类的卡的场合，可以再从自己的手卡·墓地选1只炎属性怪兽特殊召唤。「阳炎兽 斯芬克司」的这个效果1回合只能使用1次。
function c1409474.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果值为aux.tgoval，用于过滤不能成为对方效果对象的条件
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 自己的主要阶段时，宣言卡的种类（怪兽·魔法·陷阱）才能发动。自己卡组最上面的卡送去墓地，宣言的种类的卡的场合，可以再从自己的手卡·墓地选1只炎属性怪兽特殊召唤。「阳炎兽 斯芬克司」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1409474,0))  --"宣言种类"
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,1409474)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c1409474.target)
	e2:SetOperation(c1409474.operation)
	c:RegisterEffect(e2)
end
-- 目标函数，用于处理效果的发动条件和参数设置
function c1409474.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组最上面的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 向玩家提示选择卡的种类（怪兽·魔法·陷阱）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	-- 设置连锁参数为玩家宣言的卡的种类
	Duel.SetTargetParam(Duel.AnnounceType(tp))
end
-- 特殊召唤过滤函数，用于筛选符合条件的炎属性怪兽
function c1409474.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，执行特殊召唤等操作
function c1409474.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家卡组是否为空
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 将玩家卡组最上面的1张卡送去墓地
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	-- 检查玩家场上是否有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取刚刚从卡组送去墓地的卡
	local tc=Duel.GetOperatedGroup():GetFirst()
	if not tc then return end
	-- 获取当前连锁的效果参数，即玩家宣言的卡的种类
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		-- 获取玩家手卡和墓地中符合条件的炎属性怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c1409474.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		-- 判断是否有符合条件的怪兽且玩家选择发动特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1409474,1)) then  --"是否要从自己的手卡·墓地选1只炎属性怪兽特殊召唤？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
