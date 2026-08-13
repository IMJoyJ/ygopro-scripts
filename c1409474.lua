--陽炎獣 スピンクス
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。此外，自己的主要阶段时，宣言卡的种类（怪兽·魔法·陷阱）才能发动。自己卡组最上面的卡送去墓地，宣言的种类的卡的场合，可以再从自己的手卡·墓地选1只炎属性怪兽特殊召唤。「阳炎兽 斯芬克司」的这个效果1回合只能使用1次。
function c1409474.initial_effect(c)
	-- 对应效果原文：“只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置“不能成为效果对象”的判定值为aux.tgoval，即当效果的发动玩家是对方时返回true，使对方不能以这张卡为对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 对应效果原文：“此外，自己的主要阶段时，宣言卡的种类（怪兽·魔法·陷阱）才能发动。自己卡组最上面的卡送去墓地，宣言的种类的卡的场合，可以再从自己的手卡·墓地选1只炎属性怪兽特殊召唤。「阳炎兽 斯芬克司」的这个效果1回合只能使用1次。”
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
-- 起动效果的发动条件与发动时处理：先检查能否将卡组顶端1张卡送去墓地，然后提示玩家宣言怪兽·魔法·陷阱，并将宣言结果保存到连锁参数中。
function c1409474.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：己方卡组至少要有1张卡可以送去墓地，否则不能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 向玩家显示选择卡种类的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 调用Duel.AnnounceType让玩家宣言卡的种类（怪兽·魔法·陷阱），并将宣言结果存入连锁对象参数，供效果处理时使用。
	Duel.SetTargetParam(Duel.AnnounceType(tp))
end
-- 定义特殊召唤的过滤条件：选择手卡·墓地中满足炎属性且可以被特殊召唤的怪兽。
function c1409474.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理流程：把卡组顶端1张卡送去墓地，若卡组送去的卡与宣言种类一致且自己场上有空位，则选择手卡·墓地中1只炎属性怪兽特殊召唤；同时受“王家长眠之谷”影响的卡不能选。
function c1409474.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方卡组没有卡，则无法把卡组顶端的卡送去墓地，直接终止效果处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 将己方卡组顶端1张卡以效果原因送去墓地。
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	-- 检查己方主要怪兽区是否还有空位，若没有空位则不能进行特殊召唤，终止后续处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取刚才因Duel.DiscardDeck实际送去墓地的卡（即卡组顶端被送去墓地的那张卡）。
	local tc=Duel.GetOperatedGroup():GetFirst()
	if not tc then return end
	-- 从当前连锁中取出玩家发动时宣言的卡种类参数（0=怪兽，1=魔法，2=陷阱）。
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		-- 从手卡和墓地中筛选出符合条件的炎属性怪兽群，过滤条件中额外应用了王家长眠之谷的排除效果。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c1409474.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		-- 若存在可特殊召唤的怪兽，且玩家确认要特殊召唤，则继续执行特殊召唤。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1409474,1)) then  --"是否要从自己的手卡·墓地选1只炎属性怪兽特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤视为独立处理，以避免错过时点。
			Duel.BreakEffect()
			-- 显示“请选择要特殊召唤的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将玩家选择的怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
