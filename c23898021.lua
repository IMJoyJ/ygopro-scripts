--悪魔嬢リリス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：召唤的这张卡的原本攻击力变成1000。
-- ②：把自己场上1只暗属性怪兽解放才能发动。从卡组把3张通常陷阱卡给对方观看，对方从那之中随机选1张。那1张卡在自己场上盖放，剩下的卡回到卡组。这个效果在对方回合也能发动。
function c23898021.initial_effect(c)
	-- ①：召唤的这张卡的原本攻击力变成1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c23898021.regop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把自己场上1只暗属性怪兽解放才能发动。从卡组把3张通常陷阱卡给对方观看，对方从那之中随机选1张。那1张卡在自己场上盖放，剩下的卡回到卡组。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,23898021)
	e2:SetCost(c23898021.thcost)
	e2:SetTarget(c23898021.thtg)
	e2:SetOperation(c23898021.thop)
	c:RegisterEffect(e2)
end
-- 召唤成功时，给自身注册一个使原本攻击力变为1000的效果，该效果会因离场或无效化等标准重置状态而消失。
function c23898021.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：召唤的这张卡的原本攻击力变成1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 效果②发动代价：选择并解放自己场上1只暗属性怪兽；若不存在可解放的暗属性怪兽则不能发动。
function c23898021.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己场上是否存在至少1只暗属性且满足解放条件的怪兽，若没有则不能发动该效果。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_DARK) end
	-- 选择自己场上1只暗属性怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_DARK)
	-- 将选择的怪兽解放（作为COST，不计入效果处理）。
	Duel.Release(g,REASON_COST)
end
-- 定义符合条件的卡：类型为通常陷阱且可以盖放到魔陷区（即卡组中可盖放的陷阱卡）。
function c23898021.thfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 效果②的目标条件：自己魔陷区有空位，且卡组中存在至少3张满足thfilter的陷阱卡；满足条件才可发动。
function c23898021.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有空位可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在至少3张满足过滤条件的陷阱卡（用于展示并让对手选择）。
		and Duel.IsExistingMatchingCard(c23898021.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 登记操作信息：声明本连锁涉及从卡组选择卡牌（分类为回手牌、数量1），用于给予系统检测信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选出3张符合条件的陷阱卡展示给对方，对方随机选1张，将选中的卡在自己场上盖放；剩余卡留在卡组并洗切。
function c23898021.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组中取出所有满足过滤条件的陷阱卡作为候选集合。
	local g=Duel.GetMatchingGroup(c23898021.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 给发动者显示'请选择要盖放的卡'的提示，用于选择要展示的3张陷阱卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选出的3张卡展示给对手确认（对手可见这些卡）。
		Duel.ConfirmCards(1-tp,sg)
		-- 给对手显示'请选择要盖放的卡'的提示，然后由系统从已展示的卡中随机选择1张。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 处理结束后洗切发动者的卡组（因为展示的剩余卡将留在卡组并重新排列）。
		Duel.ShuffleDeck(tp)
		-- 将对方随机选中的1张陷阱卡以里侧表示盖放到发动者（tp）的魔陷区。
		Duel.SSet(tp,tg,tp,false)
	end
end
